defmodule OpentelemetryBreathalyzer.ExecuteOperation do
  use OpentelemetryBreathalyzer.Traceable

  require OpenTelemetry.SemanticConventions.Trace, as: Conventions

  alias Absinthe.Blueprint

  @graphql_document Conventions.graphql_document()
  @graphql_operation_name Conventions.graphql_operation_name()
  @graphql_operation_type Conventions.graphql_operation_type()

  @graphql_request_schema "graphql.request.schema"
  @graphql_request_selections "graphql.request.selections"
  @graphql_request_variables "graphql.request.variables"
  @graphql_request_complexity "graphql.request.complexity"

  @graphql_response_errors "graphql.response.errors"
  @graphql_response_result "graphql.response.result"

  def handle_start(name, measurement, metadata, config)

  # TODO: It might be better to extract context from phases rather than options.
  # Also, we must hide sensitive information in the context.
  # TODO: Use context.
  def handle_start(
        [:absinthe, :execute, :operation, :start] = _name,
        _measurement,
        %{blueprint: %Blueprint{input: input} = _blueprint, options: options} = _metadata,
        _config
      )
      when is_list(options) do
    with {:ok, schema} <- Keyword.fetch(options, :schema),
         {:ok, variables} <- Keyword.fetch(options, :variables),
         {:ok, variables} <- Jason.encode(variables),
         {:ok, _context} <- Keyword.fetch(options, :context) do
      attributes = [
        {@graphql_document, input},
        {@graphql_request_variables, variables},
        {@graphql_request_schema, schema}
      ]

      put_span_context_from_parent()
      span = Tracer.start_span("GraphQL Operation", %{kind: :server, attributes: attributes})

      Tracer.set_current_span(span)
    else
      _error -> nil
    end
  end

  def handle_start(_, _, _, _), do: :error

  # TODO: Set status.
  def handle_stop(
        [:absinthe, :execute, :operation, :stop] = _name,
        _measurement,
        %{blueprint: %Absinthe.Blueprint{result: result} = blueprint} = _metadata,
        _config
      ) do
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
        {@graphql_response_errors, Jason.encode!(errors)},
        {@graphql_response_result, Jason.encode!(result)}
      ]

      span_name = "#{to_string(operation_type)} #{to_string(operation_name)}"
      Tracer.update_name(span_name)

      # Tracer.set_status(status)
      Tracer.set_attributes(attributes)
      Tracer.end_span()
      restore_span_context()

      :ok
    else
      _error -> nil
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
