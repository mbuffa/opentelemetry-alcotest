defmodule OpentelemetryBreathalyzer.Graphql.Queries.ItemTest do
  use OpentelemetryBreathalyzerWeb.ConnCase
  use Wormwood.GQLCase

  load_gql(
    OpentelemetryBreathalyzerWeb.Schema,
    "test/support/web/graphql/queries/Item.gql"
  )

  describe "Item.gql" do
    test "with a simple query" do
      assert {:ok, %{data: %{"item" => %{"id" => "foo", "name" => "Foo"}}}} =
               query_gql(
                 variables: %{
                   "id" => "foo"
                 }
               )

      assert {:ok, %{data: %{"item" => nil}}} =
               query_gql(
                 variables: %{
                   "id" => "invalid-value"
                 }
               )
    end
  end
end
