defmodule OpentelemetryBreathalyzer.MixProject do
  use Mix.Project

  def project do
    [
      app: :opentelemetry_breathalyzer,
      version: "0.1.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      description: description(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:absinthe, "~> 1.7.0"},
      {:jason, "~> 1.2"},
      {:opentelemetry, "~> 1.3"},
      {:opentelemetry_api, "~> 1.2"},
      {:telemetry, "~> 0.4 or ~> 1.0"},
      # Test dependencies
      {:ecto_sql, "~> 3.10", only: :test},
      {:postgrex, ">= 0.0.0", only: :test},
      {:phoenix, "~> 1.7", only: :test},
      {:absinthe_phoenix, "~> 2.0", only: :test},
      {:wormwood, "~> 0.1.3", only: :test},
      # Required for testing Absinthe batch middlewares:
      {:opentelemetry_process_propagator, "~> 0.2.2", only: :test},
      # Dev dependencies
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: :dev}
    ]
  end

  defp docs do
    [
      main: "OpentelemetryBreathalyzer",
      formatters: ["html"]
    ]
  end

  defp description do
    "An OpenTelemetry tracer for Absinthe (with Operation, Resolve and Middleware support)."
  end

  defp package do
    [
      name: "opentelemetry_breathalyzer",
      maintainers: ["Maxime Buffa"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/mbuffa/opentelemetry-breathalyzer"}
    ]
  end

  defp aliases do
    [
      test: [
        "ecto.create --quiet",
        "ecto.migrate",
        "test"
      ]
    ]
  end
end
