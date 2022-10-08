# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :swap,
  ecto_repos: [Swap.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :swap, SwapWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: SwapWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Swap.PubSub,
  live_view: [signing_salt: "2pkE7Ns0"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tesla, adapter: Tesla.Adapter.Hackney

config :swap, client_github_base_url: "https://api.github.com"
config :swap, client_github_adapter: Swap.Clients.Github.Http

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
