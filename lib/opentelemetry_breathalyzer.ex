defmodule OpentelemetryBreathalyzer do
  @moduledoc """
  Breathalyzer is an OpenTelemetry tracker for Absinthe.

  * Add it to your dependencies:

  ```
  defp deps do
    [
      ...,
      {:opentelemetry_breathalyzer, "~> 0.1.0"}
    ]
  end
  ```

  * Configure it:

  ```
  config :opentelemetry_breathalyzer, :track,
    execute_operation: [
      request_document: true,
      request_schema: true,
      request_selections: false,
      request_variables: true,
      request_complexity: false,
      response_errors: true,
      response_result: false,
      request_context: [[:current_user, :id]]
    ]
  ```

  * And setup it just before your application supervisor starts:

  ```
    defmodule MyApplication do
      def start(_type, args) do
        opts = [strategy: :one_for_one, name: MySupervisor]
        OpentelemetryBreathalyzer.setup()
        Supervisor.start_link(children(args), opts)
    end
  end
  ```

  * There you go. You should start seeing traces popping into your OpenTelemetry store.
  """

  # Absinthe Telemetry documentation:
  # https://hexdocs.pm/absinthe/telemetry.html

  require Logger

  alias __MODULE__.{
    ExecuteOperation,
    ResolveField,
    ExecuteMiddleware
  }

  @default_config [
    execute_operation: [
      request_document: true,
      request_schema: true,
      request_selections: false,
      request_variables: true,
      request_complexity: false,
      response_errors: true,
      response_result: false,
      request_context: []
    ]
  ]

  def setup(_instrumentation_opts \\ []) do
    config = Application.get_env(:opentelemetry_breathalyzer, :track, @default_config)

    :ok = attach_execute_operation_handler(config[:execute_operation])
    :ok = attach_resolve_field_handler(config[:resolve_field])
    :ok = attach_execute_middleware_handler(config[:execute_middleware])
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
