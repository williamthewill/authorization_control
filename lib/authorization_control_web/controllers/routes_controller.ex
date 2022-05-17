defmodule AuthorizationControlWeb.RoutesController do
  @moduledoc since: "1.0.0"

  @moduledoc """

  """
  use AuthorizationControlWeb, :controller

  alias AuthorizationControl.Access.Routes

  @doc since: "1.0.0"
  def show(conn, _params) do
    routes = Routes.list_access_routes()

    conn
    |> put_status(:ok)
    |> render("index.json", routes: routes)
  end
end
