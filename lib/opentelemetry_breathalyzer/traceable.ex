defmodule OpentelemetryBreathalyzer.Traceable do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      require Record
      require OpenTelemetry.Tracer, as: Tracer

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
    end
  end
end
