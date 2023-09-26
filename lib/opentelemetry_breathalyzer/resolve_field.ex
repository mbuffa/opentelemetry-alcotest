defmodule OpentelemetryBreathalyzer.ResolveField do
  use OpentelemetryBreathalyzer.Traceable

  def handle_start(name, measurement, metadata, config)

  def handle_start(
        [:absinthe, :resolve, :field, :start],
        _measurement,
        %{
          resolution: %Absinthe.Resolution{
            arguments: _arguments,
            definition: %Absinthe.Blueprint.Document.Field{
              name: _name
            }
          }
        } = _metadata,
        _config
      ) do
    # IO.inspect(metadata)
    # IO.inspect(:resolve, measurement, label: :start)

    put_span_context_from_parent()
    span = Tracer.start_span("GraphQL Resolve", %{kind: :server, attributes: []})

    Tracer.set_current_span(span)

    :ok
  end

  def handle_stop(name, measurement, metadata, config)

  def handle_stop(
        [:absinthe, :resolve, :field, :stop],
        %{duration: _duration} = _measurement,
        %{
          resolution: %Absinthe.Resolution{
            arguments: _arguments,
            definition: %Absinthe.Blueprint.Document.Field{
              name: name
            }
          }
        } = _metadata,
        _config
      ) do
    # IO.inspect(metadata)
    # IO.inspect(:resolve, measurement, label: :stop)

    Tracer.update_name(name)

    Tracer.end_span()
    restore_span_context()

    :ok
  end
end
