defmodule OpentelemetryBreathalyzerWeb.Schema do
  use Absinthe.Schema

  @items %{
    "foo" => %{id: "foo", name: "Foo", author_id: "alice"},
    "bar" => %{id: "bar", name: "Bar", author_id: "bob"}
  }

  @users %{
    "alice" => %{id: "alice", name: "Alice"},
    "bob" => %{id: "bob", name: "Bob"}
  }

  object(:user) do
    field(:id, non_null(:id))
    field(:name, non_null(:string))
  end

  object(:item) do
    field(:id, non_null(:id))
    field(:name, non_null(:string))

    field :author, :user do
      resolve(fn item, _, _ ->
        batch({__MODULE__, :users_by_id}, item.author_id, fn batch_results ->
          {:ok, Map.get(batch_results, item.author_id)}
        end)
      end)
    end
  end

  query do
    field :item, :item do
      arg(:id, non_null(:id))

      resolve(fn %{id: item_id}, _ ->
        {:ok, @items[item_id]}
      end)
    end
  end

  def users_by_id(_, _user_ids) do
    @users
  end
end
