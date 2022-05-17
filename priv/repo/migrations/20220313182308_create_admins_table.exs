defmodule AuthorizationControl.Repo.Migrations.CreateAdminsTable do
  use Ecto.Migration

  def change do
    create table(:admins) do
      add(:email, :text, null: false)
      add(:password_hash, :text, null: false)
      add(:name, :text, null: false)
      add(:is_active, :boolean, default: true)
      add(:access_operations, {:array, :string}, default: [])
      add(:is_adam, :boolean, default: false)
      add(:first_login, :boolean, default: true)
      add(:confirmed_at, :naive_datetime)

      timestamps()
    end

    create(unique_index(:admins, [:email]))
  end
end
