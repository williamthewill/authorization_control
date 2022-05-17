defmodule AuthorizationControl.Repo.Migrations.CreateAccessRoutes do
  use Ecto.Migration

  def change do
    create table(:routes, primary_key: false) do
      add(:path, :string, primary_key: true)
      add(:message, :string, null: false)
      add(:actions, {:array, :string}, null: false)

      timestamps()

    end
  end
end
