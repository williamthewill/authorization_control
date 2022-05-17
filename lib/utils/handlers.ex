defmodule Util.Handlers do
  @moduledoc """
  Provides methods to handle query responses
  """
  @moduledoc since: "1.0.0"

  @doc """
  Function to handle get queries
  """
  @doc since: "1.0.0"
  def handle_get_one(data, name) do
    case data do
      nil -> {:error, AuthorizationControl.get_message(name).notFound}
      _ -> {:ok, data}
    end
  end

  @doc """
  Function to handle changesets
  """
  @doc since: "1.0.0"
  def handle_changeset(changeset, function) do
    case changeset do
      %{valid?: false} -> {:error, changeset}
      %{valid?: true} -> function.(changeset)
    end
  end
end
