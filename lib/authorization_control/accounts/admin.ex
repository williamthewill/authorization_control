defmodule AuthorizationControl.Accounts.Admin do
  @moduledoc """
  """
  @moduledoc since: "1.0.0"
  use AuthorizationControl.Schema
  import Ecto.Changeset
  import Utils.Crud.Util

  @params [
    :id,
    :password_hash,
    :password,
    :email,
    :name,
    :access_operations,
    :is_active,
    :is_adam,
    :first_login
  ]

  @required_params [:name]

  schema "admins" do
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:name, :string)
    field(:is_active, :boolean, default: true)
    field(:access_operations, {:array, :string})
    field(:is_adam, :boolean, default: false)
    field(:first_login, :boolean, default: true)
    field(:confirmed_at, :naive_datetime)

    timestamps()
  end

  @doc since: "1.0.0"
  def changeset(admin \\ %__MODULE__{}, params) do
    admin
    |> cast(params, [:email, :password, :name, :access_operations])
    |> validate_required(@required_params)
    |> validate_length(:access_operations, min: 1)
    |> validate_email()
    |> validate_password()
    |> maybe_hash_password()
  end

  @doc since: "1.0.0"
  def update_changeset(%__MODULE__{} = admin, params) do
    admin
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> validate_email()
    |> validate_length(:access_operations, min: 1)
  end

  @doc since: "1.0.0"
  def changeset_update(primary_key, params) do
    %__MODULE__{id: primary_key}
    |> cast(params, @params)
  end

  @spec put_is_active(%__MODULE__{}, boolean) :: Ecto.Changeset.t()
  def put_is_active(%__MODULE__{} = user, is_active) do
    change(user, is_active: is_active)
  end

  def change_password(%__MODULE__{} = admin, params) do
    admin
    |> cast(params, [:password])
    |> put_change(:first_login, false)
    |> validate_password()
    |> maybe_hash_password()
  end

  @doc since: "1.0.0"
  def confirm_email(%__MODULE__{} = admin) do
    date =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)

    change(admin, confirmed_at: date)
  end
end
