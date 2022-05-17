defmodule AuthorizationControlWeb.Controllers.Auth do
  alias AuthorizationControl.Accounts

  def current_user(%{:private => %{:guardian_default_claims => %{"sub" => admin_id}}}) do
    Accounts.get_admin(admin_id)
  end
end
