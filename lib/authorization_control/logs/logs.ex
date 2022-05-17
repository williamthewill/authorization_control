defmodule AuthorizationControl.Logs do
  alias Helpers.Pagination
  alias AuthorizationControl.Logs.Log
  alias AuthorizationControl.Repo

  import Ecto.Query

  def list_paginated(criteria) do
    Log
    |> apply_filters(criteria)
    |> Pagination.paginate_query(criteria)
  end

  defp apply_filters(query, criteria) do
    Enum.reduce(criteria, query, &handle_filters/2)
  end

  defp handle_filters({:change_agent, ""}, query), do: query

  defp handle_filters({:change_agent, change_agent}, query) do
    from(q in query, where: ilike(q.change_agent, ^"%#{change_agent}"))
  end

  defp handle_filters({:message, ""}, query), do: query

  defp handle_filters({:message, message}, query) do
    from(q in query, where: ilike(q.message, ^"%#{message}"))
  end

  defp handle_filters({:start_date, ""}, query), do: query

  defp handle_filters({:start_date, start_date}, query) do
    from(q in query, where: q.inserted_at <= ^start_date)
  end

  defp handle_filters({:end_date, ""}, query), do: query

  defp handle_filters({:end_date, end_date}, query) do
    from(q in query, where: q.inserted_at >= ^end_date)
  end

  defp handle_filters(_, query), do: query

  def toggle_is_active(change_agent, target, params) do
    change_agent
    |> Log.ToggleIsActive.build(target, params)
    |> Repo.insert()
  end

  def create_resource(change_agent, resource, attrs) do
    change_agent
    |> Log.CreateResource.build(resource, attrs)
    |> Repo.insert()
  end

  def edit_resource(change_agent, resource, attrs) do
    change_agent
    |> Log.EditResource.build(resource, attrs)
    |> Repo.insert()
  end
end
