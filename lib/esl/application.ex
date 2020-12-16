defmodule Esl.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Esl.{TopStories, HackerNews}
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      EslWeb.Endpoint,
      HackerNews.Supervisor,
      TopStories.Supervisor
    ]

    opts = [strategy: :one_for_one, name: Esl.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EslWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
