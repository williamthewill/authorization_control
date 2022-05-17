defmodule AuthorizationControlWeb.OperationsView do
  use AuthorizationControlWeb, :view

  def render("index.json", %{operations: operations}) do
    operations
  end

  def render("index.json", %{operation_detail: operation_detail}) do
    keys = Map.keys(operation_detail)

    Enum.map(keys, fn key ->
      %{
        path: key,
        actions: operation_detail[key]
      }
    end)
  end

  @doc since: "1.0.0"
  def render("create.json", %{operation: operation}) do
    %{
      name: operation.name,
      actionsRoutes: operation.actions_routes
    }
  end

  @doc since: "1.0.0"
  # def render("create.json", %{operation: %Operations{} = operation}) do
  def render("update.json", %{operation: operation}) do
    %{
      name: operation.name,
      actionsRoutes: operation.actions_routes
    }
  end
end
