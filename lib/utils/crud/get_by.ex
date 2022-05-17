defmodule Utils.Crud.GetBy do
  @moduledoc """
  Provides methods to fetch a register from the database, using the given params
  """
  @moduledoc since: "1.0.0"

  alias AuthorizationControl.Repo

  @doc """
  Fetches a single register in the database using the given params
  Params needs to be a keyword list

  Returns `{:ok, response} | {:error, reason}`

  ## Examples

      iex> params = [name: "teste"]
      %{name: teste}
      iex> Crud.GetBy.call(ApiLapidar.Stores, "Store", params)
      {:ok, response}

      iex> params = [name: "batata"]
      %{name: batata}
      iex> Crud.GetBy.call(ApiLapidar.Stores, "Store", params)
      nil
  """
  @doc since: "1.0.0"
  def call(params, schema) do
    schema
    |> Repo.get_by(params)
  end
end
