defmodule OpentelemetryBreathalyzer.ExecuteMiddlewareTest do
  use OpentelemetryBreathalyzer.SpanCase, async: false

  setup do
    OpentelemetryBreathalyzer.attach_execute_middleware_handler(%{})

    {:ok, query} = File.read("test/support/web/graphql/queries/Item.gql")

    {:ok, data} =
      Absinthe.run(query, OpentelemetryBreathalyzerWeb.Schema, variables: %{"id" => "foo"})

    on_exit(fn ->
      OpentelemetryBreathalyzer.detach_execute_middleware_handler()
    end)

    {:ok, %{data: data}}
  end

  test "span name" do
    assert_receive {:span, span(name: "GraphQL Middleware Batch alice")}, 5000
  end

  test "span kind" do
    assert_receive {:span, span(kind: :server)}, 5000
  end

  test "attributes" do
    assert_receive {:span, span}, 5000
    span(attributes: {:attributes, _, _, _, attributes}) = span

    assert attributes == %{
             "graphql.batch.fun" => "Elixir.OpentelemetryBreathalyzerWeb.Schema;users_by_id",
             "graphql.batch.opts" => "[]",
             "graphql.batch.result" =>
               "Elixir.OpentelemetryBreathalyzerWeb.Schema;users_by_id;alice;id;alice;name;Alice;bob;id;bob;name;Bob"
           }
  end

  test "data", %{data: data} do
    assert %{
             data: %{
               "item" => %{
                 "author" => %{"id" => "alice", "name" => "Alice"},
                 "id" => "foo",
                 "name" => "Foo"
               }
             }
           } == data
  end
end
