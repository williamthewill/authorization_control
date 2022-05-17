defmodule Utils.Crud.Update do
  @moduledoc """
  Provides methods to update a existing register into the database
  """
  @moduledoc since: "1.0.0"

  alias AuthorizationControl.Repo
  alias Util.Handlers

  @doc """
  Fetch a existing register from the database, using the given primary_key (can be a keyword list or a single value)
  Create a new changeset using the given params and validate it
  If the changeset is valid, updates the register into the database
  If not, return an error tuple with the changeset or a message

  Returns `{:ok, response} | {:error, %Ecto.Changeset{}} | {:error, reason}`

  ## Examples

      iex> params = %{name: teste, cnpj: "123", conta_id: "123456"}
      %{name: teste, cnpj: "123", conta_id: "123456"}
      iex> Crud.Update.call(ApiLapidar.Stores, "Store", "4bbebc79-1d51-4969-8a82-7d359343fc38", params)
      {:ok, response}

      iex> params = %{name: teste, cnpj: "123"}
      %{name: teste, cnpj: "123", conta_id: "123456"}
      iex> Crud.Update.call(ApiLapidar.Stores, "Store", "4bbebc79-1d51-4969-8a82-7d359343fc38", params)
      {:error, %Ecto.Changeset{}}

      iex> params = %{name: teste, cnpj: "123", conta_id: "123456"}
      %{name: teste, cnpj: "123", conta_id: "123456"}
      iex> Crud.Update.call(ApiLapidar.Stores, "Store", "123", params)
      {:error, "Store not found!"}
  """
  @doc since: "1.0.0"
  def call(primary_key, params, schema, _name) do
    primary_key
    |> schema.changeset_update(params)
    |> Handlers.handle_changeset(&Repo.update/1)
  end
end
