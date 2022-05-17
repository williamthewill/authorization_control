defmodule AuthorizationControl.Repo.Migrations.CreateOperations do
  use Ecto.Migration

  def change do
    create table(:operations, primary_key: false) do
      add(:name, :text, primary_key: true)
      add(:actions_routes, :map, null: false)

      timestamps()
    end
  end
end
