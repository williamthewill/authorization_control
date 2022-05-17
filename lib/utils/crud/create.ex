defmodule Utils.Crud.Create do
  @moduledoc """
  Provides methods to create a new register into the database
  """
  @moduledoc since: "1.0.0"

  alias AuthorizationControl.Repo
  alias Util.Handlers

  @doc """
  Create a new changeset using the given params and validate it
  If the changeset is valid, creates new register into the database
  If not, return an error tuple with the changeset

  Returns `{:ok, response} | {:error, %Ecto.Changeset{}}`

  ## Examples

      iex> params = %{name: teste, cnpj: "123", conta_id: "123456"}
      %{name: teste, cnpj: "123", conta_id: "123456"}
      iex> Crud.Create.call(ApiLapidar.Stores, params)
      {:ok, response}

      iex> params = %{name: teste, cnpj: "123"}
      %{name: teste, cnpj: "123"}
      iex> Crud.Create.call(ApiLapidar.Stores, params)
      {:error, %Ecto.Changeset{}}
  """
  @doc since: "1.0.0"
  def call(params, schema) do
    params
    |> schema.changeset()
    |> Handlers.handle_changeset(&Repo.insert/1)
  end
end
