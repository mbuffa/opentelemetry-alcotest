defmodule OpentelemetryAlcotest.Common.JsonEncoder do
  require Logger

  def encode(nil), do: "{}"

  def encode(enum) when is_map(enum) do
    Enum.flat_map(enum, fn {k, v} ->
      ["\"#{k}\":", encode(v)]
    end)
    |> List.insert_at(0, "{")
    |> List.insert_at(-1, "}")
    |> Enum.join()
  end

  def encode(value) when is_binary(value) do
    "\"#{value}\""
  end

  def encode(value) when is_bitstring(value) do
    "\"[REDACTED]\""
  end

  def encode(enum) when is_list(enum) do
    Enum.map(enum, &encode/1)
    |> Enum.join(",")
    |> then(fn str -> "[#{str}]" end)
  end

  def encode(value) when is_atom(value) do
    Atom.to_string(value)
  end

  def encode(value) when is_number(value) do
    to_string(value)
  end

  def encode(value) do
    Logger.warning("Alcotest.JsonEncoder.encode/1: unsupported type #{inspect(value)}")

    "\"[REDACTED]\""
  end
end
