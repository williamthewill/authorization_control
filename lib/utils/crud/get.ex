defmodule Utils.Crud.Get do
  @moduledoc """
  Provides methods to fetch a register from the database, using the ID
  """
  @moduledoc since: "1.0.0"

  alias AuthorizationControl.Repo

  @doc """
  Fetches a single register in the database using the given ID

  Returns `{:ok, response} | {:error, reason}`

  ## Examples

      iex> Crud.Get.call(ApiLapidar.Stores, "Store", "4bbebc79-1d51-4969-8a82-7d359343fc38")
      {:ok, response}

      iex> Crud.Get.call(ApiLapidar.Stores, "Store", "123")
      nil
  """
  @doc since: "1.0.0"
  def call(id, schema) do
    schema
    |> Repo.get(id)
  end
end
