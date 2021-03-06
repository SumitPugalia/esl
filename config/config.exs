# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :esl, EslWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "1RqmhumUIlwgsXUpjVvSmWTVrVD1hms5WtKRkP/UuHFBqYL7RoifGGVfEiRU1yci",
  render_errors: [view: EslWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Esl.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :esl, :poll_period, 
  hacker_news: 300 # IN Seconds

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
