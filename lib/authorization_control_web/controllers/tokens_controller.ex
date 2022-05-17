defmodule AuthorizationControlWeb.TokensController do
  use AuthorizationControlWeb, :controller

  alias AuthorizationControl.Accounts

  action_fallback(AuthorizationControlWeb.FallbackController)

  def create(conn, %{"email" => email, "send_to" => send_to}) do
    with {:ok, {_account_type, account}} <- AuthorizationControl.get_client_by_login(email),
         {:ok, _user_token} <- Accounts.recover_password(account, send_to) do
      conn
      |> put_status(:no_content)
      |> text("")
    end
  end

  def confirm_password(conn, %{"token" => token} = params) do
    with {:ok, user} <- Accounts.get_user_by_token(token),
         {:ok, _user_token} <- Accounts.change_password(user, params) do
      conn
      |> put_status(:no_content)
      |> text("")
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    with {:ok, account_token} <- Accounts.get_token(token),
         {:ok, _user_token} <- Accounts.confirm_email(account_token) do
      conn
      |> put_status(:no_content)
      |> text("")
    end
  end
end
