defmodule OpentelemetryBreathalyzer.MixProject do
  use Mix.Project

  def project do
    [
      app: :opentelemetry_breathalyzer,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
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
      {:opentelemetry_api, "~> 1.1"},
      {:telemetry, "~> 0.4 or ~> 1.0"},
      # Test dependencies
      {:ecto_sql, "~> 3.10", only: :test},
      {:postgrex, ">= 0.0.0", only: :test},
      {:phoenix, "~> 1.7", only: :test},
      {:absinthe_phoenix, "~> 2.0", only: :test},
      {:wormwood, "~> 0.1.3", only: :test},
      {:opentelemetry_exporter, "~> 1.4", only: :test},
      {:opentelemetry_ecto, "~> 1.1", only: :test},
      {:opentelemetry_phoenix, "~> 1.1", only: :test},
      # Dev dependencies
      {:credo, "~> 1.7", only: :dev}
    ]
  end

  defp docs do
    [
      main: "OpentelemetryBreathalyzer",
      formatters: ["html"]
    ]
  end

  defp package do
    [
      name: "opentelemetry-breathalyzer",
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
