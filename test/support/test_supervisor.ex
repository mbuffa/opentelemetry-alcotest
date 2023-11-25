defmodule TestSupervisor do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: OpentelemetryBreathalyzer.Supervisor]

    Supervisor.start_link(children(), opts)
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
