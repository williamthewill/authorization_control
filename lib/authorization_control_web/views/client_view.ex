defmodule AuthorizationControlWeb.ClientView do
  use AuthorizationControlWeb, :view

  alias AuthorizationControl.Accounts.{Admin, User}

  def render("index.json", %{
        admins: %{data: admins, paging: paging}
      }) do
    %{
      admins: render_many(admins, __MODULE__, "admin.json", as: :client),
      paging: paging
    }
  end

  def render("show.json", %{admin: admin}) do
    %{admin: render_one(admin, __MODULE__, "admin.json")}
  end

  def render("show.json", %{user: user}) do
    %{user: render_one(user, __MODULE__, "user.json")}
  end

  def render("admin.json", %{
        client: %Admin{
          id: id,
          name: name,
          access_operations: access_operations,
          is_active: is_active,
          email: email
        }
      }) do
    %{
      id: id,
      name: name,
      email: email,
      accessOperations: access_operations,
      isActive: is_active
    }
  end

  def render("user.json", %{
        client: %User{
          id: id,
          email: email,
          name: name,
          cpf: cpf,
          external_load_id: external_load_id,
          phone: phone,
          is_active: is_active
        }
      }) do
    %{
      id: id,
      email: email,
      name: name,
      cpf: cpf,
      external_load_id: external_load_id,
      phone: phone,
      is_active: is_active
    }
  end

  def render("login.json", %{token: token}) do
    %{token: token}
  end

  def render("no_response.txt", _) do
    ""
  end
end
