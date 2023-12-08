defmodule OpentelemetryBreathalyzer.ExecuteMiddlewareTest do
  use OpentelemetryBreathalyzer.SpanCase, async: false

  setup do
    OpentelemetryBreathalyzer.attach_handler(:execute_middleware, %{})

    {:ok, query} = File.read("test/support/web/graphql/queries/Item.gql")

    {:ok, data} =
      Absinthe.run(query, OpentelemetryBreathalyzerWeb.Schema, variables: %{"id" => "foo"})

    on_exit(fn ->
      OpentelemetryBreathalyzer.detach_handler(:execute_middleware)
    end)

    {:ok, %{data: data}}
  end

  test "span name" do
    assert_receive {:span, span(name: "GraphQL Middleware Batch 1")}, 5000
  end

  test "span kind" do
    assert_receive {:span, span(kind: :server)}, 5000
  end

  test "attributes" do
    assert_receive {:span, span}, 5000
    span(attributes: {:attributes, _, _, _, attributes}) = span

    assert %{
             "graphql.batch.fun" => "Elixir.OpentelemetryBreathalyzerWeb.Schema;users_by_id",
             "graphql.batch.opts" => "[]",
             "graphql.batch.result" =>
               "Elixir.OpentelemetryBreathalyzerWeb.Schema;users_by_id;1;id;1;name;Alice;2;id;2;name;Bob"
           } == attributes
  end

  test "data", %{data: data} do
    assert %{
             data: %{
               "item" => %{
                 "author" => %{"id" => "1", "name" => "Alice"},
                 "id" => "foo",
                 "name" => "Foo"
               }
             }
           } == data
  end
end
