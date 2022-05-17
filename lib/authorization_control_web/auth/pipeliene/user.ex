defmodule AuthorizationControlWeb.Auth.Pipeline.User do
  use Guardian.Plug.Pipeline,
    otp_app: :authorization_control,
    error_handler: AuthorizationControlWeb.Auth.ErrorHandler,
    module: AuthorizationControlWeb.Auth.Guardian

  plug(Guardian.Plug.VerifyHeader)
  plug(Guardian.Plug.EnsureAuthenticated, claims: %{"typ" => "access", "account" => "user"})
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
