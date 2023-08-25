defmodule OpentelemetryAlcotestTest do
  use ExUnit.Case
  doctest OpentelemetryAlcotest

  test "greets the world" do
    assert OpentelemetryAlcotest.hello() == :world
  end
end
