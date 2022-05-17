defmodule Utils.Crud.Util do
  import Ecto.Changeset

  alias Ecto.Changeset

  @email_format ~r/^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/

  def validate_email(%Changeset{} = changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, @email_format)
    |> validate_length(:email, max: 160)
    |> unique_constraint(:email)
  end

  def validate_password(%Changeset{} = changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 5, max: 80)
    |> validate_password_confirmation()
  end

  def validate_password_confirmation(%Changeset{valid?: true} = changeset) do
    validate_confirmation(changeset, :password)
  end

  def validate_password_confirmation(%Changeset{valid?: false} = changeset) do
    changeset
  end

  def maybe_hash_password(%Changeset{valid?: true} = changeset) do
    password = get_change(changeset, :password)
    password_hash = Argon2.hash_pwd_salt(password)

    changeset
    |> put_change(:password_hash, password_hash)
    |> delete_change(:password)
  end

  def maybe_hash_password(%Changeset{valid?: false} = changeset) do
    changeset
  end
end
