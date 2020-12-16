defmodule EslWeb.Router do
  use EslWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", EslWeb do
    pipe_through :api
  end
end