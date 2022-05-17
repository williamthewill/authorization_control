defmodule AuthorizationControl.Access.Routes.Route do
  @moduledoc """

  """
  @moduledoc since: "1.0.0"

  use AuthorizationControl.Schema

  import Ecto.Changeset

  @primary_key false
  schema "routes" do
    field(:path, :string, null: false, unique: true)
    field(:message, :string, null: false)
    field(:actions, {:array, :string}, null: false)

    timestamps()
  end

  def changeset(%__MODULE__{} = access_routes, params \\ %{}) do
    access_routes
    |> cast(params, [:path, :actions])
    |> validate_required([:path, :actions])
  end
end
