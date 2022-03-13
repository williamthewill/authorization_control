defmodule AuthorizationControl.Repo do
  use Ecto.Repo,
    otp_app: :authorization_control,
    adapter: Ecto.Adapters.Postgres
end
