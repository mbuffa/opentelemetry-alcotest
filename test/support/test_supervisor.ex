defmodule TestSupervisor do
  use Application

  @impl true
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: OpentelemetryBreathalyzer.Supervisor]

    :ok = setup_opentelemetry()

    Supervisor.start_link(children(), opts)
  end

  defp setup_opentelemetry do
    :ok = OpentelemetryBreathalyzer.setup()
    :ok = OpentelemetryEcto.setup([:opentelemetry_breathalyzer, :repo])
    :ok = OpentelemetryPhoenix.setup()
  end

  defp children do
    [
      {Phoenix.PubSub, name: OpentelemetryBreathalyzer.PubSub},
      OpentelemetryBreathalyzer.Repo,
      OpentelemetryBreathalyzerWeb.Telemetry,
      OpentelemetryBreathalyzerWeb.Endpoint,
      {Absinthe.Subscription, OpentelemetryBreathalyzerWeb.Endpoint}
    ]
  end
end
