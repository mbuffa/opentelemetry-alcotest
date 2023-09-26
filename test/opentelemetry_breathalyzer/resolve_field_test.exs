defmodule OpentelemetryBreathalyzer.ResolveFieldTest do
  use OpentelemetryBreathalyzer.SpanCase, async: false

  setup do
    OpentelemetryBreathalyzer.attach_resolve_field_handler(%{})

    {:ok, query} = File.read("test/support/web/graphql/queries/Item.gql")

    {:ok, data} =
      Absinthe.run(query, OpentelemetryBreathalyzerWeb.Schema, variables: %{"id" => "foo"})

    on_exit(fn ->
      OpentelemetryBreathalyzer.detach_resolve_field_handler()
    end)

    {:ok, %{data: data}}
  end

  test "span name" do
    assert_receive {:span, span(name: "item")}, 5000
  end

  test "span kind" do
    assert_receive {:span, span(kind: :server)}, 5000
  end

  test "attributes" do
    assert_receive {:span, span}, 5000
    span(attributes: {:attributes, _, _, _, attributes}) = span
    assert attributes == %{}
  end
end
