defmodule EslWeb.Router do
  use EslWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", EslWeb do
    pipe_through :browser
    get "/", TopStoriesController, :index
  end

  scope "/api", EslWeb do
    pipe_through :api
    get "/top_stories", TopStoriesController, :list
    get "/detail/:id", TopStoriesController, :detail
  end
end
