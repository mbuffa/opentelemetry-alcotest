# OpenTelemetry Breathalyzer

Breathalyzer is an OpenTelemetry tracker for Absinthe. It
supports the most useful metrics Absinthe exposes, and should be relatively
safe to use for production, although it is in early testing still.

Breathalyzer supports tracking operations, field and batches resolutions.

## Contributing

Please feel free to open issues, fork and open pull requests.

Constructive criticism is always appreciated. Also, `TODO.md` and `TODO`
annotations should be a good start if you're looking for easy improvements.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `opentelemetry_breathalyzer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:opentelemetry_breathalyzer, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/opentelemetry_breathalyzer>.

