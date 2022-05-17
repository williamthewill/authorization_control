defmodule AuthorizationControl.Access.Operations do
  @moduledoc """
  The providers context.
  """

  import Ecto.Query

  alias AuthorizationControl.Access.Operations.Operation
  alias AuthorizationControl.{Logs, Repo}

  @doc since: "1.0.0"
  @spec get_operation(String.t()) :: {:ok, Operation.t()} | {:error, :operation_not_found}
  def get_operation(name) do
    Repo.one(
      from(op in Operation,
        where: op.name == ^name
      )
    )
    |> get_operation_response
  end

  @doc since: "1.0.0"
  @spec get_operation_detail(String.t()) :: {:ok, any} | {:error, :operation_not_found}
  def get_operation_detail(name) do
    Repo.one(
      from(op in Operation,
        where: op.name == ^name,
        select: op.actions_routes
      )
    )
    |> get_operation_detail_response
  end

  @doc since: "1.0.0"
  def list_operations(params) do
    query =
      from(op in Operation,
        select: op.name
      )

    name = params["name"]

    query =
      if name do
        from(q in query,
          where: q.name == ^name
        )
      else
        query
      end

    Repo.all(query)
  end

  @doc since: "1.0.0"
  def create_operation(params, opts \\ []) do
    IO.inspect("params===============")
    IO.inspect(params)
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:operation, Operation.changeset(%Operation{}, params))
    |> Ecto.Multi.run(:log, fn _, %{operation: operation} ->
      opts
      |> Keyword.get(:change_agent)
      |> Logs.create_resource(operation, params)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{operation: operation}} ->
        {:ok, operation}

      {:error, _step, reason, _processed} ->
        {:error, reason}
    end
  end

  @doc since: "1.0.0"
  def update_operation(%Operation{} = operation, params, opts \\ []) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:operation, Operation.changeset(operation, params))
    |> Ecto.Multi.run(:log, fn _, %{operation: operation} ->
      opts
      |> Keyword.get(:change_agent)
      |> Logs.edit_resource(operation, params)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{operation: operation}} ->
        {:ok, operation}

      {:error, _step, reason, _processed} ->
        {:error, reason}
    end
  end

  defp get_operation_response(nil), do: {:error, :operation_not_found}
  defp get_operation_response(%Operation{} = operation), do: {:ok, operation}

  defp get_operation_detail_response(nil), do: {:error, :operation_not_found}
  defp get_operation_detail_response(operation_detail), do: {:ok, operation_detail}
end
