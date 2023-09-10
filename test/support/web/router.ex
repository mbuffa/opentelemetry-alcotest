defmodule Web.Router do
  use Web, :router

  pipeline :api do
    plug(:accepts, ["json", "multipart"])
  end

  scope "/" do
    pipe_through(:api)

    forward("/", Absinthe.Plug,
      schema: Web.Schema,
      socket: Web.Socket
    )
  end
end
