defmodule AuthorizationControl.Accounts.Searchs.Users do
  import Ecto.Query

  alias Helpers.Pagination
  alias AuthorizationControl.Accounts.User

  def execute(criteria) do
    User
    |> apply_filters(criteria)
    |> Pagination.paginate_query(criteria)
  end

  defp apply_filters(query, criteria) do
    Enum.reduce(criteria, query, &handle_filters/2)
  end

  defp handle_filters({:name, ""}, query) do
    query
  end

  defp handle_filters({:name, name}, query) do
    from(q in query, where: ilike(q.name, ^"%#{name}%"))
  end

  defp handle_filters({:email, ""}, query) do
    query
  end

  defp handle_filters({:email, email}, query) do
    from(q in query, where: ilike(q.email, ^"%#{email}%"))
  end

  defp handle_filters({:external_load_id, ""}, query) do
    query
  end

  defp handle_filters({:external_load_id, external_load_id}, query) do
    from(q in query, where: ilike(q.external_load_id, ^"%#{external_load_id}%"))
  end

  defp handle_filters({:is_active, nil}, query) do
    query
  end

  defp handle_filters({:is_active, is_active}, query) do
    from(q in query, where: q.is_active == ^is_active)
  end

  defp handle_filters(_, query) do
    query
  end
end
