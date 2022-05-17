defmodule AuthorizationControlWeb.ClientController do
  use AuthorizationControlWeb, :controller

  alias AuthorizationControlWeb.Auth.Guardian
  alias AuthorizationControlWeb.ClientControllerSchemas
  alias AuthorizationControl.Accounts
  alias AuthorizationControl.Accounts.{Admin, User}
  alias AuthorizationControl.Access.Operations.Operation
  alias AuthorizationControlWeb.Controllers.Auth

  alias AuthorizationControl.Repo
  import Ecto.Query

  action_fallback(AuthorizationControlWeb.FallbackController)

  def identify_client(email) do
    case AuthorizationControl.get_client_by([email: email], User) do
      nil ->
        case AuthorizationControl.get_client_by([email: email], Admin) do
          nil ->
            Util.Handlers.handle_get_one(nil, "Client")

          admin ->
            IO.inspect("is_admin")
            IO.inspect(admin)
            {:ok, {:admin, Map.put(admin, :operations, get_opearations(admin))}}
        end

      user ->
        {:ok, {:user, user}}
    end
  end

  defp get_opearations(admin) do
    Repo.all(
      from(op in Operation,
        where: op.name in ^admin.access_operations,
        select: {op.name, op.actions_routes}
      )
    )
    |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end

  def index(conn, %{"search_param" => search_param} = params) do
    admins =
      params
      |> pagination_params()
      |> Accounts.list_admins(search_param)

    conn
    |> put_status(:ok)
    |> render("index.json", admins: admins)
  end

  def index(conn, params) do
    admins =
      params
      |> pagination_params()
      |> Accounts.list_admins()

    conn
    |> put_status(:ok)
    |> render("index.json", admins: admins)
  end

  defp pagination_params(params) do
    [
      page: params["page"],
      page_size: params["page_size"]
    ]
  end

  def show(conn, %{"id" => id}) do
    with {:ok, admin} <- Accounts.get_admin(id) do
      conn
      |> put_status(:ok)
      |> render("show.json", admin: admin)
    end
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"send_to" => send_to} = params) do
    with {:ok, change_agent} <- Auth.current_user(conn),
         {:ok, admin} <- Accounts.create_admin(send_to, params, change_agent: change_agent) do
      conn
      |> put_status(:created)
      |> render("show.json", admin: admin)
    end
  end

  @spec create_user(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create_user(conn, %{"send_to" => send_to} = params) do
    with {:ok, user} <- Accounts.create_user(send_to, params) do
      conn
      |> put_status(:created)
      |> render("show.json", user: user)
    end
  end

  def update_admin(conn, params) do
    IO.inspect("banana")
    with {:ok, validated_params} <-
           ClientControllerSchemas.update_admin_schema(params),
         {:ok, change_agent} <- Auth.current_user(conn),
         {:ok, admin} <- Accounts.get_admin(validated_params.id),
         {:ok, admin} <- Accounts.update_admin(admin, validated_params, change_agent: change_agent) do
      conn
      |> put_status(:ok)
      |> render("show.json", admin: admin)
    end
  end

  def toggle_is_active(conn, %{"id" => id}) do
    with {:ok, change_agent} <- Auth.current_user(conn),
         {:ok, admin} <- Accounts.get_admin(id),
         {:ok, admin} <- Accounts.toggle_admin_is_active(admin, change_agent: change_agent) do
      conn
      |> put_status(:ok)
      |> render("show.json", admin: admin)
    end
  end

  def login_admin(conn, params) do
    with {:ok, %{email: email, password: password}} <-
           ClientControllerSchemas.login_schema(params),
         {:ok, {:admin, client}} <- Guardian.authenticate(email, password) do
      do_login(conn, :admin, client, email)
    end
  end

  def login_user(conn, params) do
    with {:ok, %{email: email, password: password}} <-
           ClientControllerSchemas.login_schema(params),
         {:ok, {:user, client}} <- Guardian.authenticate(email, password) do
      do_login(conn, :user, client, email)
    end
  end

  defp do_login(conn, account_type, client, email) do
    with {:ok, true} <- Guardian.verify_authorization(conn, account_type),
         {:ok, true} <- Guardian.verify_email(email),
         {:ok, true} <- Guardian.verify_active(client),
         {:ok, token} <- Guardian.create_token(account_type, client) do
      conn
      |> put_status(201)
      |> render("login.json", token: token)
    end
  end

  def change_password(conn, params) do
    with {:ok,
          %{
            email: email,
            old_password: old_password,
            new_password: new_password,
            password_confirmation: password_confirmation
          }} <-
           ClientControllerSchemas.change_password_schema(params),
         {:ok, {account, client}} <- Guardian.authenticate(email, old_password),
         {:ok, true} <- Guardian.verify_authorization(conn, account),
         {:ok, _account} <-
           Accounts.change_password(client, %{
             password: new_password,
             password_confirmation: password_confirmation
           }) do
      conn
      |> put_status(201)
      |> json("Password changed")
    end
  end
end
