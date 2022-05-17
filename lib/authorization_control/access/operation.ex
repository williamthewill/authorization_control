defmodule AuthorizationControl.Access.Operations.Operation do
  @moduledoc """

  """
  @moduledoc since: "1.0.0"

  use AuthorizationControl.Schema

  import Ecto.Changeset

  @primary_key false
  schema "operations" do
    field(:name, :string, primary_key: true)
    field(:actions_routes, :map)

    timestamps()
  end

  def changeset(%__MODULE__{} = operation, params \\ %{}) do
    operation
    |> cast(params, [:name, :actions_routes])
    |> validate_required([:name, :actions_routes])
    |> unique_constraint(:name)
  end
end
