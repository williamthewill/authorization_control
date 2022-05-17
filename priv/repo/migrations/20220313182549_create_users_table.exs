defmodule AuthorizationControl.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :text, null: false)
      add(:password_hash, :text, null: false)
      add(:external_load_id, :text, null: false)
      add(:name, :text, null: false)
      add(:cpf, :varchar, size: 11, null: false)
      add(:phone, :text, null: false)
      add(:is_active, :boolean, default: true)
      add(:confirmed_at, :naive_datetime)

      timestamps()
    end

    create(unique_index(:users, [:email]))
    create(unique_index(:users, [:cpf]))
    create(unique_index(:users, [:external_load_id]))
  end
end
