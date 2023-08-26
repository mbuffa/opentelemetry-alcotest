defmodule OpentelemetryAlcotest.Operation do
  require OpenTelemetry.Tracer, as: Tracer
  require OpenTelemetry.SemanticConventions.Trace, as: Conventions
  require Record

  alias Absinthe.Blueprint
  alias OpentelemetryAlcotest.Common.JsonEncoder

  @graphql_document Conventions.graphql_document()
  @graphql_operation_name Conventions.graphql_operation_name()
  @graphql_operation_type Conventions.graphql_operation_type()

  @graphql_request_schema "graphql.request.schema"
  @graphql_request_selections "graphql.request.selections"
  @graphql_request_variables "graphql.request.variables"
  @graphql_request_complexity "graphql.request.complexity"

  @graphql_response_errors "graphql.response.errors"
  @graphql_response_result "graphql.response.result"

  @span_ctx_fields Record.extract(:span_ctx,
                     from_lib: "opentelemetry_api/include/opentelemetry.hrl"
                   )

  Record.defrecord(:span_ctx, @span_ctx_fields)

  @ctx_key {__MODULE__, :parent_ctx}
  defp put_span_context_from_parent do
    ctx = Tracer.current_span_ctx()
    Process.put(@ctx_key, ctx)
  end

  defp restore_span_context do
    ctx = Process.get(@ctx_key, :undefined)
    Process.delete(@ctx_key)
    Tracer.set_current_span(ctx)
  end

  def handle_operation_start(name, measurement, metadata, config)

  # TODO: It might be better to extract context from phases rather than options.
  # Also, we must hide sensitive information in the context.
  # TODO: Use context.
  def handle_operation_start(
        [:absinthe, :execute, :operation, :start] = _name,
        _measurement,
        %{blueprint: %Blueprint{input: input} = _blueprint, options: options} = _metadata,
        _config
      )
      when is_list(options) do
    with {:ok, schema} <- Keyword.fetch(options, :schema),
         {:ok, variables} <- Keyword.fetch(options, :variables),
         {:ok, variables} <- serialize_variables(variables),
         {:ok, _context} <- Keyword.fetch(options, :context) do
      # IO.inspect({:start, :name, name}, limit: :infinity)
      # IO.inspect({:start, :measurement, measurement}, limit: :infinity)
      # IO.inspect({:start, :metadata, metadata}, limit: :infinity)
      # IO.inspect({:start, schema, input, variables, context}, limit: :infinity)

      attributes = [
        {@graphql_document, input},
        {@graphql_request_variables, variables},
        {@graphql_request_schema, schema}
      ]

      put_span_context_from_parent()
      span = Tracer.start_span("GraphQL Operation", %{kind: :server, attributes: attributes})

      Tracer.set_current_span(span)
    else
      error ->
        IO.inspect({:start_failed, error})
    end
  end

  def handle_operation_start(_, _, _, _), do: :error

  # TODO: Add status depending on errors.
  def handle_operation_stop(
        [:absinthe, :execute, :operation, :stop] = _name,
        _measurement,
        %{blueprint: %Absinthe.Blueprint{result: result} = blueprint} = _metadata,
        _config
      ) do
    # IO.inspect({:stop, :name, name}, limit: :infinity)
    # IO.inspect({:stop, :measurement, measurement}, limit: :infinity)
    # IO.inspect({:stop, :metadata, metadata}, limit: :infinity)

    with %Absinthe.Blueprint.Document.Operation{
           name: operation_name,
           type: operation_type,
           selections: operation_selections,
           complexity: operation_complexity,
           errors: errors
         } <- Absinthe.Blueprint.current_operation(blueprint),
         operation_selections <-
           serialize_selections(operation_selections) do
      attributes = [
        {@graphql_operation_type, operation_type},
        {@graphql_operation_name, operation_name},
        {@graphql_request_selections, operation_selections},
        {@graphql_request_complexity, operation_complexity},
        {@graphql_response_errors, JsonEncoder.encode(errors)},
        {@graphql_response_result, JsonEncoder.encode(result)}
      ]

      span_name = "#{to_string(operation_type)} #{to_string(operation_name)}"
      Tracer.update_name(span_name)

      # Tracer.set_status(status)
      Tracer.set_attributes(attributes)
      Tracer.end_span()
      restore_span_context()

      :ok
    else
      error ->
        IO.inspect({:stop_failed, error})
    end
  end

  # TODO: Handle types that can't be serialized (like binary strings)
  defp serialize_variables(%{} = variables) do
    case JsonEncoder.encode(variables) do
      str when is_binary(str) ->
        {:ok, str}

      err ->
        {:error, "Parse error: #{inspect(err)}"}
    end
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

  # TODO: There might be more relevant info here.
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
