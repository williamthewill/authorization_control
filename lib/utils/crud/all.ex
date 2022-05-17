defmodule Utils.Crud.All do
  @moduledoc """
  Provides methods to fetch all registers on the given schema
  """
  @moduledoc since: "1.0.0"

  alias AuthorizationControl.Repo

  @doc """
  Fetches all registers on the given schema
  Returns `{:ok, [...]} | {:error, reason}`

  ## Examples

      iex> Crud.All.call(ApiLapidar.Stores)
      {:ok, [...]}

      iex> Crud.All.call(ApiLapidar.Stores)
      {:error, reason}
  """
  @doc since: "1.0.0"
  def call!(value) do
    value
    |> Repo.all()
  end
end
