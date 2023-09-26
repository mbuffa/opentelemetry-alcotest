defmodule OpentelemetryBreathalyzer.ExecuteOperationTest do
  use OpentelemetryBreathalyzer.SpanCase, async: false

  setup do
    OpentelemetryBreathalyzer.attach_execute_operation_handler(%{})

    {:ok, query} = File.read("test/support/web/graphql/queries/Item.gql")

    {:ok, data} =
      Absinthe.run(query, OpentelemetryBreathalyzerWeb.Schema, variables: %{"id" => "foo"})

    on_exit(fn ->
      OpentelemetryBreathalyzer.detach_execute_operation_handler()
    end)

    {:ok, %{data: data}}
  end

  test "span name" do
    assert_receive {:span, span(name: "query Item")}, 5000
  end

  test "span kind" do
    assert_receive {:span, span(kind: :server)}, 5000
  end

  test "attributes" do
    assert_receive {:span, span}, 5000
    span(attributes: {:attributes, _, _, _, attributes}) = span

    assert %{
             :"graphql.document" =>
               "query Item($id: ID!) {\n  item(id: $id) {\n    id\n    name\n    author {\n      id\n      name\n    }\n  }\n}",
             :"graphql.operation.name" => "Item",
             :"graphql.operation.type" => :query,
             "graphql.request.complexity" => nil,
             "graphql.request.schema" => OpentelemetryBreathalyzerWeb.Schema,
             "graphql.request.variables" => "{\"id\":\"foo\"}",
             "graphql.response.errors" => "[]",
             "graphql.response.result" =>
               "{\"data\":{\"item\":{\"author\":{\"id\":\"alice\",\"name\":\"Alice\"},\"id\":\"foo\",\"name\":\"Foo\"}}}"
           } == attributes
  end
end
