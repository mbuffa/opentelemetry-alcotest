defmodule OpentelemetryBreathalyzer.ExecuteOperation do
  @moduledoc false

  use OpentelemetryBreathalyzer.Traceable

  require OpenTelemetry.SemanticConventions.Trace, as: Conventions
  require Logger

  alias Absinthe.Blueprint
  alias OpentelemetryBreathalyzer.Util

  @graphql_document Conventions.graphql_document()
  @graphql_operation_name Conventions.graphql_operation_name()
  @graphql_operation_type Conventions.graphql_operation_type()

  @graphql_request_schema "graphql.request.schema"
  @graphql_request_selections "graphql.request.selections"
  @graphql_request_variables "graphql.request.variables"
  @graphql_request_complexity "graphql.request.complexity"
  @graphql_request_context "graphql.request.context"

  @graphql_response_errors "graphql.response.errors"
  @graphql_response_result "graphql.response.result"

  def handle_start(name, measurement, metadata, config)

  def handle_start(
        [:absinthe, :execute, :operation, :start] = _name,
        _measurement,
        %{blueprint: %Blueprint{input: input} = _blueprint, options: options} = _metadata,
        config
      )
      when is_list(options) do
    with {:ok, schema} <- Keyword.fetch(options, :schema),
         {:ok, variables} <- Keyword.fetch(options, :variables),
         {:ok, variables} <- Jason.encode(variables),
         {:ok, context} <- Keyword.fetch(options, :context) do
      attributes =
        []
        |> Util.append({@graphql_document, input}, fn ->
          config[:request_document]
        end)
        |> Util.append({@graphql_request_variables, variables}, fn ->
          config[:request_variables]
        end)
        |> Util.append({@graphql_request_schema, schema}, fn ->
          config[:request_schema]
        end)
        |> Util.append_lazy(
          fn ->
            trace_context =
              (config[:request_context] || [])
              |> Enum.reduce(%{}, fn nested_path, acc ->
                value = extract_context(context, nested_path)

                Map.put(acc, Enum.join(nested_path, "."), value)
              end)

            {@graphql_request_context, Jason.encode!(trace_context)}
          end,
          fn -> config[:request_context] != [] end
        )

      put_span_context_from_parent()
      span = Tracer.start_span("GraphQL Operation", %{kind: :server, attributes: attributes})

      Tracer.set_current_span(span)
    else
      _error -> nil
    end
  end

  def handle_start(_, _, _, _), do: :error

  defp extract_context(%{} = context, nested_path) do
    get_in(context, nested_path)
  end

  defp extract_context(context, _) do
    Logger.warning("Unsupported context #{inspect(context)}")
    nil
  end

  def handle_stop(
        [:absinthe, :execute, :operation, :stop] = _name,
        _measurement,
        %{blueprint: %Absinthe.Blueprint{result: result} = blueprint} = _metadata,
        config
      ) do
    case Absinthe.Blueprint.current_operation(blueprint) do
      %Absinthe.Blueprint.Document.Operation{
        name: operation_name,
        type: operation_type
      } = operation ->
        attributes = build_final_attributes(operation, result, config)

        span_name = "#{to_string(operation_type)} #{to_string(operation_name)}"
        Tracer.update_name(span_name)

        Tracer.set_attributes(attributes)
        Tracer.end_span()
        restore_span_context()

        :ok

      _ ->
        :error
    end
  end

  defp build_final_attributes(
         %Absinthe.Blueprint.Document.Operation{
           name: operation_name,
           type: operation_type,
           selections: operation_selections,
           complexity: operation_complexity,
           errors: errors
         },
         result,
         config
       ) do
    []
    |> Util.append({@graphql_operation_type, operation_type})
    |> Util.append({@graphql_operation_name, operation_name})
    |> Util.append_lazy(
      fn ->
        {@graphql_request_selections, serialize_selections(operation_selections)}
      end,
      fn -> config[:request_selections] end
    )
    |> Util.append({@graphql_request_complexity, operation_complexity}, fn ->
      config[:request_complexity]
    end)
    |> Util.append_lazy(
      fn ->
        case Jason.encode(errors) do
          {:ok, encoded_errors} ->
            {@graphql_response_errors, encoded_errors}

          {:error, error} ->
            {@graphql_response_errors, Jason.encode!(error)}
        end
      end,
      fn ->
        config[:response_errors]
      end
    )
    |> Util.append_lazy(
      fn ->
        case Jason.encode(result) do
          {:ok, encoded_result} ->
            {@graphql_response_result, encoded_result}

          {:error, error} ->
            {@graphql_response_result, Jason.encode!(error)}
        end
      end,
      fn ->
        config[:response_result]
      end
    )
  end

  defp serialize_selections(selections) when is_list(selections) do
    Enum.map(selections, &serialize_field/1)
  end

  defp serialize_field(%Absinthe.Blueprint.Document.Field{
         name: name,
         selections: selections,
         arguments: arguments
       }) do
    %{
      name: name,
      selections: serialize_selections(selections),
      arguments: serialize_arguments(arguments)
    }
  end

  defp serialize_field(%Absinthe.Blueprint.Document.Field{
         name: name,
         arguments: arguments
       }) do
    %{name: name, arguments: serialize_arguments(arguments)}
  end

  defp serialize_field(%Absinthe.Blueprint.Document.Fragment.Spread{}), do: "*"

  # TODO: Check for relevant info here.
  defp serialize_field(%Absinthe.Blueprint.Document.Fragment.Inline{
         selections: selections,
         type_condition: %Absinthe.Blueprint.TypeReference.Name{name: name}
       }) do
    %{name: name, selections: serialize_selections(selections)}
  end

  defp serialize_arguments([]), do: []

  defp serialize_arguments(arguments) when is_list(arguments) do
    Enum.map(arguments, &serialize_argument/1)
  end

  defp serialize_argument(%Absinthe.Blueprint.Input.Argument{
         name: name,
         value: value
       }) do
    %{name => value}
  end
end
