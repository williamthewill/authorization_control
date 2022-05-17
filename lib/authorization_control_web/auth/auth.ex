defmodule AuthorizationControlWeb.Auth do
  import Plug.Conn

  alias AuthorizationControlWeb.Auth.Guardian
  alias Phoenix.Controller

  @doc since: "1.0.0"
  @spec authenticate_admin(
          Plug.Conn.t(),
          any
        ) :: Plug.Conn.t()
  def authenticate_admin(conn, _opts) do
    email = get_session(conn, :email) || ""
    password = get_session(conn, :password) || ""

    case Guardian.authenticate(email, password) do
      {:ok, _client} ->
        conn

      {:error, "Invalid credentials"} ->
        conn
        |> Controller.redirect(to: "/backoffice")
        |> halt()
    end
  end

  @doc since: "1.0.0"
  @spec session_pipe(
          Plug.Conn.t(),
          any
        ) :: Plug.Conn.t()
  def session_pipe(conn, _) do
    conn |> assign(:web_session, true)
  end
end
