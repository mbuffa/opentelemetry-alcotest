defmodule TestSupervisor do
  use Application

  @impl true
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: OpentelemetryBreathalyzer.Supervisor]

    :ok = setup_opentelemetry()

    Supervisor.start_link(children(), opts)
  end

  defp setup_opentelemetry do
    OpentelemetryBreathalyzer.setup()
  end

  defp children do
    [
      {Phoenix.PubSub, name: OpentelemetryBreathalyzer.PubSub},
      OpentelemetryBreathalyzer.Repo,
      Web.Telemetry,
      Web.Endpoint,
      {Absinthe.Subscription, Web.Endpoint}
    ]
  end
end
