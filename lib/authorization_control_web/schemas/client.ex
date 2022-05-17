defmodule AuthorizationControlWeb.ClientControllerSchemas do
  @moduledoc """
  Module to define params schema to wallet routes
  """
  @moduledoc since: "1.0.0"

  alias Util.Middleware

  @doc since: "1.0.0"
  def login_schema(params) do
    Middleware.prepar(%{
      email: params["email"],
      password: params["password"]
    })
  end

  def update_admin_schema(params) do
    Middleware.prepar(%{
      id: params["id"],
      email: params["email"] || :not_setted,
      password: params["password"] || :not_setted,
      name: params["name"] || :not_setted,
      is_active: params["isActive"] || :not_setted,
      access_operations: params["access_operations"] || :not_setted
    })
  end

  def update_user_schema(params) do
    Middleware.prepar(%{
      email: params["email"],
      password: params["password"],
      phone: params["phone"],
      is_active: params["is_active"]
    })
  end

  def change_password_schema(params) do
    Middleware.prepar(%{
      email: params["email"],
      old_password: params["old_password"],
      new_password: params["new_password"],
      password_confirmation: params["password_confirmation"]
    })
  end
end
