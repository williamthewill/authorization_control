defmodule Helpers.Pagination do
  @moduledoc """
  Provides functions for pagination
  """

  import Helpers.PaginationQuery

  alias AuthorizationControl.Repo

  @type t(data) :: %{
          data: data,
          paging: %{
            page: integer,
            total: integer,
            pages: integer
          }
        }

  def paginate_query(query, criteria) do
    total_records = total_records(query)

    page = String.to_integer(Keyword.get(criteria, :page) || "1")
    page_size = String.to_integer(Keyword.get(criteria, :page_size) || "10")

    %{
      data: paginate_records(query, page, page_size),
      paging: %{
        page: page,
        pages: total_pages(total_records, page_size),
        total: total_records
      }
    }
  end

  defp total_records(query), do: Repo.aggregate(query, :count, :id)

  defp total_pages(total_records, page_size), do: ceil(total_records / page_size)

  defp paginate_records(query, page, page_size) do
    query
    |> paginate_query(page, page_size)
    |> Repo.all()
  end
end
