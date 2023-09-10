defmodule OpentelemetryBreathalyzerWeb.Router do
  use OpentelemetryBreathalyzerWeb, :router

  pipeline :api do
    plug(:accepts, ["json", "multipart"])
  end

  scope "/" do
    pipe_through(:api)

    forward("/", Absinthe.Plug,
      schema: OpentelemetryBreathalyzerWeb.Schema,
      socket: OpentelemetryBreathalyzerWeb.Socket
    )
  end
end
