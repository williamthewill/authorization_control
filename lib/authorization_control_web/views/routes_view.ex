defmodule AuthorizationControlWeb.RoutesView do
  use AuthorizationControlWeb, :view

  def render("index.json", %{routes: routes}) do
    Enum.map(routes, fn route ->
      %{
        path: route.path,
        message: route.message,
        actions: route.actions
      }
    end)
  end
end
