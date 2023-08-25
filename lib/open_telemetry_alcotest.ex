defmodule OpenTelemetryAlcotest do
  @moduledoc """
  Documentation for `OpenTelemetryAlcotest`.

  TODO
  """

  # Absinthe Telemetry documentation:
  # https://hexdocs.pm/absinthe/telemetry.html

  require Logger

  alias __MODULE__.Operation

  def setup(_instrumentation_opts \\ []) do
    # FIXME
    config = %{}

    :telemetry.attach(
      {Operation, :operation_start},
      [:absinthe, :execute, :operation, :start],
      &Operation.handle_operation_start/4,
      config
    )

    :telemetry.attach(
      {Operation, :operation_stop},
      [:absinthe, :execute, :operation, :stop],
      &Operation.handle_operation_stop/4,
      config
    )
  end

  def teardown do
    :telemetry.detach({Operation, :operation_start})
    :telemetry.detach({Operation, :operation_stop})
  end
end
