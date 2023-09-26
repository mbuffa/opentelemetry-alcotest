defmodule OpentelemetryBreathalyzer.SpanCase do
  use ExUnit.CaseTemplate

  setup do
    :otel_simple_processor.set_exporter(:otel_exporter_pid, self())

    # on_exit(fn ->
    #   OpentelemetryBreathalyzer.teardown()
    #   :ok
    # end)
  end

  using do
    quote do
      # Use Record module to extract fields of the Span record from the opentelemetry dependency.
      require Record
      @fields Record.extract(:span, from: "deps/opentelemetry/include/otel_span.hrl")
      # Define macros for `Span`.
      Record.defrecordp(:span, @fields)
    end
  end
end
