import Config

config :opentelemetry_breathalyzer, OpentelemetryBreathalyzerWeb.Endpoint,
  http: [port: 4002],
  server: false,
  pubsub_server: OpentelemetryBreathalyzer.PubSub

config :opentelemetry_breathalyzer, OpentelemetryBreathalyzer.Repo,
  database: "opentelemetry_breathalyzer_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  password: "postgres",
  username: "postgres",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 15,
  queue_target: 2000

config :opentelemetry_breathalyzer, ecto_repos: [OpentelemetryBreathalyzer.Repo]

config :opentelemetry,
  traces_exporter: :none

config :opentelemetry, :processors, [
  {:otel_simple_processor, %{}}
]
