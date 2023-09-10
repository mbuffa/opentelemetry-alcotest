defmodule Web.GQLSubscriptionCase do
  @moduledoc false

  use ExUnit.CaseTemplate
  alias Absinthe.Phoenix.SubscriptionTest

  using(opts) do
    quote do
      # Import conveniences for testing with channels
      import Phoenix.ChannelTest

      # The default endpoint for testing
      @endpoint Web.Endpoint

      use Absinthe.Phoenix.SubscriptionTest,
        schema: Keyword.fetch!(unquote(opts), :schema)

      @socket Keyword.fetch!(unquote(opts), :socket)

      import Web.GQLSubscriptionCase

      defp get_socket_and_subscribe(endpoint, socket_params \\ %{}) do
        case get_socket(endpoint, socket_params) do
          {:ok, socket} ->
            SubscriptionTest.join_absinthe(socket)

          :error ->
            :error
        end
      end

      defp get_socket(endpoint, socket_params \\ %{}) do
        Phoenix.ChannelTest.__connect__(
          endpoint,
          @socket,
          socket_params,
          []
        )
      end

      defp subscribe(socket, query, opts \\ []) do
        ref = push_doc(socket, query, opts)
        assert_reply(ref, :ok, %{subscriptionId: subscription_id})
        {:ok, subscription_id, ref}
      end
    end
  end
end
