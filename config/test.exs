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
       :processors,
       otel_batch_processor: %{
         # Using `localhost` here since we are starting outside docker-compose where
         # otel would refer to the hostname of the OpenCollector,
         #
         # If you are running in docker compose, kindly change it to the correct
         # hostname: `otel`
         exporter: {:opentelemetry_exporter, %{endpoints: [{:http, "localhost", 4318, []}]}}
       }
