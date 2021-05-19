# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :components,
  ecto_repos: [Components.Repo]

# Configures the endpoint
config :components, ComponentsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VFnzI1Q7e4NIczGYdRN20GrxWw6ZFgvGU8vzebpINlrhXtQ4KOA10WKwiohwyQib",
  render_errors: [view: ComponentsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Components.PubSub,
  live_view: [signing_salt: "gSZzSHiH"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
