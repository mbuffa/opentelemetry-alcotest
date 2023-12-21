defmodule OpentelemetryBreathalyzer.ExecuteOperation.AllAttributesTest do
  use OpentelemetryBreathalyzer.SpanCase, async: false

  setup_all do
    config = %{
      execute_operation: [
        request_document: true,
        request_schema: true,
        request_selections: true,
        request_variables: true,
        request_complexity: true,
        response_errors: true,
        response_result: true,
        request_context: [[:current_user, :id]]
      ]
    }

    OpentelemetryBreathalyzer.attach_handler(:execute_operation, config[:execute_operation])

    on_exit(fn ->
      OpentelemetryBreathalyzer.detach_handler(:execute_operation)
    end)
  end

  describe "with all attributes traced" do
    setup do
      {:ok, query} = File.read("test/support/web/graphql/queries/Item.gql")

      {:ok, data} =
        Absinthe.run(query, OpentelemetryBreathalyzerWeb.Schema, variables: %{"id" => "foo"})

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

      assert %{:"graphql.operation.name" => "Item"} = attributes
      assert %{:"graphql.operation.type" => :query} = attributes
      assert %{"graphql.request.complexity" => nil} = attributes
      assert %{"graphql.request.schema" => OpentelemetryBreathalyzerWeb.Schema} = attributes
      assert %{"graphql.request.variables" => "{\"id\":\"foo\"}"} = attributes
      assert %{"graphql.response.errors" => "[]"} = attributes

      assert %{
               "graphql.response.result" =>
                 "{\"data\":{\"item\":{\"author\":{\"id\":\"1\",\"name\":\"Alice\"},\"id\":\"foo\",\"name\":\"Foo\"}}}"
             } = attributes

      assert %{"graphql.request.context" => "{\"current_user.id\":null}"} = attributes
    end
  end
end
