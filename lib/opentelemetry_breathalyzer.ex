defmodule OpentelemetryBreathalyzer do
  @moduledoc """
  Breathalyzer is an OpenTelemetry tracer for Absinthe.

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
  config :opentelemetry_breathalyzer, :trace,
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
  ```

  * You may also choose to start only a couple of handlers:
  ```
  defmodule MyApplication do
    def start(_type, args) do
      opts = [strategy: :one_for_one, name: MySupervisor]
      OpentelemetryBreathalyzer.setup(only: [:execute_operation, :execute_middleware]])
      Supervisor.start_link(children(args), opts)
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

  @default_handlers [
    :execute_operation,
    :resolve_field,
    :execute_middleware
  ]

  def setup(instrumentation_opts \\ []) do
    config = Application.get_env(:opentelemetry_breathalyzer, :trace, @default_config)

    Keyword.get(instrumentation_opts, :only, @default_handlers)
    |> Enum.each(fn
      atom when is_atom(atom) ->
        attach_handler(atom, config[atom])

      _ ->
        raise "Unsupported :only configuration. Supported values are: :execute_operation, :resolve_field, :execute_middleware"
    end)
  end

  def teardown do
    detach_handler(:execute_operation)
    detach_handler(:resolve_field)
    detach_handler(:execute_middleware)
  end

  def attach_handler(type, config \\ %{})

  def attach_handler(:execute_operation, config) do
    with :ok <-
           :telemetry.attach(
             {ExecuteOperation, :start},
             [:absinthe, :execute, :operation, :start],
             &ExecuteOperation.handle_start/4,
             config
           ),
         :ok <-
           :telemetry.attach(
             {ExecuteOperation, :stop},
             [:absinthe, :execute, :operation, :stop],
             &ExecuteOperation.handle_stop/4,
             config
           ) do
      :ok
    end
  end

  def attach_handler(:resolve_field, config) do
    with :ok <-
           :telemetry.attach(
             {ResolveField, :start},
             [:absinthe, :resolve, :field, :start],
             &ResolveField.handle_start/4,
             config
           ),
         :ok <-
           :telemetry.attach(
             {ResolveField, :stop},
             [:absinthe, :resolve, :field, :stop],
             &ResolveField.handle_stop/4,
             config
           ) do
      :ok
    end
  end

  def attach_handler(:execute_middleware, config) do
    with :ok <-
           :telemetry.attach(
             {ExecuteMiddleware, :start},
             [:absinthe, :middleware, :batch, :start],
             &ExecuteMiddleware.handle_start/4,
             config
           ),
         :ok <-
           :telemetry.attach(
             {ExecuteMiddleware, :stop},
             [:absinthe, :middleware, :batch, :stop],
             &ExecuteMiddleware.handle_stop/4,
             config
           ) do
      :ok
    end
  end

  def detach_handler(:execute_operation) do
    :telemetry.detach({ExecuteOperation, :start})
    :telemetry.detach({ExecuteOperation, :stop})
  end

  def detach_handler(:resolve_field) do
    :telemetry.detach({ResolveField, :start})
    :telemetry.detach({ResolveField, :stop})
  end

  def detach_handler(:execute_middleware) do
    :telemetry.detach({ExecuteMiddleware, :start})
    :telemetry.detach({ExecuteMiddleware, :stop})
  end
end
