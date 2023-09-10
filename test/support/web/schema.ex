defmodule Web.Schema do
  use Absinthe.Schema

  @items %{
    "foo" => %{id: "foo", name: "Foo"},
    "bar" => %{id: "bar", name: "Bar"}
  }

  object(:item) do
    field(:id, non_null(:id))
    field(:name, non_null(:string))
  end

  query do
    field :item, :item do
      arg(:id, non_null(:id))

      resolve(fn %{id: item_id}, _ ->
        {:ok, @items[item_id]}
      end)
    end
  end
end
