defmodule AuthorizationControl.Accounts.User do
  use AuthorizationControl.Schema
  import Ecto.Changeset
  import Utils.Crud.Util

  @params [
    :id,
    :email,
    :password_hash,
    :external_load_id,
    :name,
    :cpf,
    :phone,
    :is_active
  ]

  schema "users" do
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:external_load_id, :string)
    field(:name, :string)
    field(:cpf, :string)
    field(:phone, :string)
    field(:is_active, :boolean, default: true)
    field(:confirmed_at, :naive_datetime)

    timestamps()
  end

  @doc since: "1.0.0"
  def changeset(user \\ %__MODULE__{}, params) do
    user
    |> cast(params, [:email, :password, :name, :cpf, :external_load_id, :phone])
    |> validate_required([:email, :name, :external_load_id, :phone, :cpf])
    |> validate_email()
    |> validate_password()
    |> maybe_hash_password()
    |> unique_constraint(:cpf)
    |> unique_constraint(:external_load_id)
    |> validate_length(:name, min: 5, max: 120)
  end

  def update_changeset(%__MODULE__{} = user, params) do
    user
    |> cast(params, [:email, :name, :phone, :is_active])
    |> validate_required([:name, :phone, :is_active])
    |> validate_email()
    |> validate_length(:name, min: 5, max: 120)
  end

  def change_password(%__MODULE__{} = user, params) do
    user
    |> cast(params, [:password])
    |> validate_password()
    |> maybe_hash_password()
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

  @doc since: "1.0.0"
  def confirm_email(%__MODULE__{} = user) do
    date =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)

    change(user, confirmed_at: date)
  end
end
