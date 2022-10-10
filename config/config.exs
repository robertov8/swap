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

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase
config :swap, oban_enabled: Mix.env() == :dev || System.get_env("OBAN_ENABLED")

config :swap, Oban,
  repo: Swap.Repo,
  prefix: "jobs",
  queues: [
    default: 1,
    schedule_repository_stories: 10,
    repository_stories: 1,
    schedule_webhooks: 10,
    webhooks: 1
  ],
  plugins: [
    {Oban.Plugins.Pruner, max_age: 86400},
    {
      Oban.Plugins.Cron,
      timezone: "America/Sao_Paulo",
      crontab: [
        {"@daily", Swap.Workers.ScheduleWebhooksWorker},
        {"@hourly", Swap.Workers.ScheduleRepositoryStoriesWorker}
      ]
    }
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
