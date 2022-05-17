defmodule Helpers.PaginationQuery do
  import Ecto.Query

  def paginate_query(query, page, page_size) do
    query
    |> offset([q], ^((page - 1) * page_size))
    |> limit([q], ^page_size)
  end
end
