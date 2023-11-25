defmodule OpentelemetryBreathalyzer.ExecuteMiddleware do
  @moduledoc false
  use OpentelemetryBreathalyzer.Traceable

  @graphql_batch_fun "graphql.batch.fun"
  @graphql_batch_opts "graphql.batch.opts"
  @graphql_batch_result "graphql.batch.result"

  def handle_start(name, measurement, metadata, config)

  def handle_start(
        [:absinthe, :middleware, :batch, :start],
        _measurement,
        %{
          batch_data: batch_data
        } = _metadata,
        _config
      ) do
    put_span_context_from_parent()

    name = to_str(batch_data)
    span = Tracer.start_span("GraphQL Middleware Batch #{name}", %{kind: :server, attributes: []})

    Tracer.set_current_span(span)

    :ok
  end

  def handle_stop(name, measurement, metadata, config)

  def handle_stop(
        [:absinthe, :middleware, :batch, :stop],
        _measurement,
        %{
          batch_fun: batch_fun,
          batch_opts: batch_opts,
          result: result
        } = _metadata,
        _config
      ) do
    attributes = [
      {@graphql_batch_fun, to_str(batch_fun)},
      {@graphql_batch_opts, to_str(batch_opts)},
      {@graphql_batch_result, to_str(result)}
    ]

    Tracer.set_attributes(attributes)
    Tracer.end_span()
    restore_span_context()

    :ok
  end

  # TODO: Review and write unit tests for this (or use Jason).

  defp to_str(tuple) when is_tuple(tuple) do
    tuple
    |> Tuple.to_list()
    |> to_str()
  end

  defp to_str([]), do: "[]"

  defp to_str(list) when is_list(list) do
    list
    |> Enum.map_join(";", &to_str/1)
  end

  defp to_str(%{} = map) do
    map
    |> Map.to_list()
    |> to_str()
  end

  defp to_str(something) do
    to_string(something)
  end
end
