defmodule AuthorizationControlWeb.Plug.HealthCheck do
  use AuthorizationControlWeb, :controller
  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{request_path: "/v1/health"} = conn, _opts) do
    conn
    |> send_resp(200, "")
    |> halt()
  end

  def call(conn, _opts), do: conn
end
