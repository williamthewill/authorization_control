defmodule AuthorizationControl.Logs.Log do
  use Ecto.Schema

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id
  schema "logs" do
    field :message, :string
    field :metadata, :map
    field :change_agent, :binary_id

    timestamps()
  end
end
