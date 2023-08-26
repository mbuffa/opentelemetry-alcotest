defmodule Common.JsonEncoderTest do
  use ExUnit.Case

  alias OpentelemetryAlcotest.Common.JsonEncoder, as: Encoder

  describe "encode/1" do
    test "with nil" do
      input = nil
      expected = "{}"
      assert Encoder.encode(input) == expected
    end

    test "with an empty map" do
      input = %{}
      expected = "{}"
      assert Encoder.encode(input) == expected
    end

    test "with a nested integer" do
      input = %{
        "input" => %{
          "userId" => 1
        }
      }

      expected = "{\"input\":{\"userId\":1}}"
      assert Encoder.encode(input) == expected
    end

    test "with a nested list of integers" do
      input = %{
        "input" => %{
          "userIds" => [1, 2, 3]
        }
      }

      expected = "{\"input\":{\"userIds\":[1,2,3]}}"
      assert Encoder.encode(input) == expected
    end

    test "with a nested string" do
      input = %{
        "input" => %{
          "userIds" => "Hello world"
        }
      }

      expected = "{\"input\":{\"userIds\":\"Hello world\"}}"
      assert Encoder.encode(input) == expected
    end

    test "with a nested bitstring" do
      input = %{
        "input" => %{
          "token" => <<3::4>>
        }
      }

      expected = "{\"input\":{\"token\":\"[REDACTED]\"}}"
      assert Encoder.encode(input) == expected
    end
  end
end
