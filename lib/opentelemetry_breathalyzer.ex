defmodule OpentelemetryBreathalyzer do
  @moduledoc """
  Documentation for `OpentelemetryBreathalyzer`.

  TODO
  """

  # Absinthe Telemetry documentation:
  # https://hexdocs.pm/absinthe/telemetry.html

  require Logger

  alias __MODULE__.{
    ExecuteOperation,
    ResolveField,
    ExecuteMiddleware
  }

  def setup(_instrumentation_opts \\ []) do
    # FIXME: Pull actual configuration from env
    config = %{}

    :ok = attach_execute_operation_handler(config)
    :ok = attach_resolve_field_handler(config)
    :ok = attach_execute_middleware_handler(config)
  end

  def teardown do
    detach_execute_operation_handler()
    detach_resolve_field_handler()
    detach_execute_middleware_handler()
  end

  def attach_execute_operation_handler(config) do
    :ok =
      :telemetry.attach(
        {ExecuteOperation, :start},
        [:absinthe, :execute, :operation, :start],
        &ExecuteOperation.handle_start/4,
        config
      )

    :ok =
      :telemetry.attach(
        {ExecuteOperation, :stop},
        [:absinthe, :execute, :operation, :stop],
        &ExecuteOperation.handle_stop/4,
        config
      )
  end

  def detach_execute_operation_handler do
    :telemetry.detach({ExecuteOperation, :start})
    :telemetry.detach({ExecuteOperation, :stop})
  end

  def attach_resolve_field_handler(config) do
    :ok =
      :telemetry.attach(
        {ResolveField, :start},
        [:absinthe, :resolve, :field, :start],
        &ResolveField.handle_start/4,
        config
      )

    :ok =
      :telemetry.attach(
        {ResolveField, :stop},
        [:absinthe, :resolve, :field, :stop],
        &ResolveField.handle_stop/4,
        config
      )
  end

  def detach_resolve_field_handler() do
    :telemetry.detach({ResolveField, :start})
    :telemetry.detach({ResolveField, :stop})
  end

  def attach_execute_middleware_handler(config) do
    :ok =
      :telemetry.attach(
        {ExecuteMiddleware, :start},
        [:absinthe, :middleware, :batch, :start],
        &ExecuteMiddleware.handle_start/4,
        config
      )

    :ok =
      :telemetry.attach(
        {ExecuteMiddleware, :stop},
        [:absinthe, :middleware, :batch, :stop],
        &ExecuteMiddleware.handle_stop/4,
        config
      )
  end

  def detach_execute_middleware_handler() do
    :telemetry.detach({ExecuteMiddleware, :start})
    :telemetry.detach({ExecuteMiddleware, :stop})
  end
end
