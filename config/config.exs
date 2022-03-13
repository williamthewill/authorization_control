# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :authorization_control,
  ecto_repos: [AuthorizationControl.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :authorization_control, AuthorizationControlWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+caUWv4ifUlUDgn7Xv6kYcAaP5qL4fC3KJQouHZnCWf0ENNj6kWY1WcCleNTW0gF",
  render_errors: [view: AuthorizationControlWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: AuthorizationControl.PubSub,
  live_view: [signing_salt: "IaGsXY6P"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
