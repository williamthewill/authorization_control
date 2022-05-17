defmodule AuthorizationControlWeb.Plug.AdminAuthorization do
  use AuthorizationControlWeb, :controller
  import Plug.Conn
  alias AuthorizationControlWeb.Auth.Guardian

  def init(opts), do: opts

  def call(conn, _opts) do
    IO.inspect("call admin_auth")
    IO.inspect(conn)
    with {:ok, _res} <- Guardian.verify_authorization(conn, :admin) do
      conn
    else
      {:error, error, code} ->
        conn
        |> put_status(:bad_request)
        |> put_view(AuthorizationControlWeb.ErrorView)
        |> render("400.json",
          code: code,
          message: error
        )
        |> halt()

      _ ->
        conn
        |> put_status(400)
        |> json(%{error: "unexpected_error"})
        |> halt()
    end
  end
end
