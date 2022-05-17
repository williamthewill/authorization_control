defmodule AuthorizationControlWeb.OperationsController do
  @moduledoc since: "1.0.0"

  @moduledoc """

  """
  use AuthorizationControlWeb, :controller

  alias AuthorizationControl.Access.Operations
  alias AuthorizationControlWeb.Controllers.Auth

  @doc since: "1.0.0"
  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"name" => name} = _params) do
    case Operations.get_operation_detail(name) do
      {:ok, operation_detail} ->
        conn
        |> put_status(:ok)
        |> render("index.json", operation_detail: operation_detail)

      {:error, error} ->
        conn
        |> put_status(400)
        |> json(%{error: error})
    end
  end

  @doc since: "1.0.0"
  def index(conn, params) do
    operations = Operations.list_operations(params)

    conn
    |> put_status(:ok)
    |> render("index.json", operations: operations)
  end

  @doc since: "1.0.0"
  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, params) do
    with {:ok, admin} <- Auth.current_user(conn),
          {:ok, operation} <- Operations.create_operation(params, change_agent: admin) do
      conn
      |> put_status(:created)
      |> render("create.json", operation: operation)
    end
  end

  @doc since: "1.0.0"
  @spec update(Plug.Conn.t(), map) :: Plug.Conn.t()
  def update(conn, %{"name" => name} = params) do
    with {:ok, admin} <- Auth.current_user(conn),
          {:ok, operation} <- Operations.get_operation(name),
         {:ok, updated_operation} <- Operations.update_operation(operation, params, change_agent: admin) do
      conn
      |> put_status(:ok)
      |> render("update.json", operation: updated_operation)
    else
      {:error, error} ->
        conn
        |> put_status(400)
        |> json(%{error: error})

      _ ->
        conn
        |> put_status(400)
        |> json(%{error: "unexpected_error"})
    end
  end
end
