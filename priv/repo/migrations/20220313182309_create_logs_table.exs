defmodule AuthorizationControl.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs) do
      add :message, :string
      add :metadata, :map
      add :change_agent, references(:admins, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:logs, [:change_agent])
  end
end
