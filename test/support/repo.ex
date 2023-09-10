defmodule OpentelemetryBreathalyzer.Repo do
  use Ecto.Repo,
    otp_app: :opentelemetry_breathalyzer,
    adapter: Ecto.Adapters.Postgres
end
