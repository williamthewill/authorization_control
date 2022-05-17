defmodule AuthorizationControl.Access.Routes do
  @moduledoc """
  The providers context.
  """

  import Ecto.Query

  alias AuthorizationControl.Access.Routes.Route
  alias AuthorizationControl.Repo

  @doc since: "1.0.0"
  def list_access_routes do
    Repo.all(Route)
  end
end
