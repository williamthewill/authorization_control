defmodule AuthorizationControl.Accounts.Client do
  alias AuthorizationControl.Accounts.{Admin, User}

  def schema_by_account(:user), do: User
  def schema_by_account(:admin), do: Admin
end
