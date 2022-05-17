defmodule AuthorizationControlWeb.Plug.SnakeCaseParams do
  def init(opts), do: opts

  def call(%{params: params} = conn, _opts) do
    %{conn | params: to_snake_case(params)}
  end

  def to_snake_case(map) when is_map(map) do
    try do
      for {key, val} <- map,
          into: %{},
          do: {snake_case(key), to_snake_case(val)}
    rescue
      # Not Enumerable
      Protocol.UndefinedError -> map
    end
  end

  def to_snake_case(list) when is_list(list) do
    list
    |> Enum.map(&to_snake_case/1)
  end

  def to_snake_case(other_types), do: other_types

  def snake_case(val) when is_atom(val) do
    val
    |> Atom.to_string()
    |> Macro.underscore()
  end

  def snake_case(val) when is_number(val) do
    val
  end

  def snake_case(val) when is_nil(val) do
    val
  end

  def snake_case(val) do
    case is_ignore_key(val) do
      true ->
        val

      _ ->
        val
        |> String.replace(" ", "")
        |> Macro.underscore()
    end
  end

  def is_ignore_key(key) do
    ["[GET]", "[POST]", "[PUT]", "[UPDATE]", "[PATCH]"]
    |> Enum.reduce(false, fn x, acc -> String.contains?(key, x) || acc end)
  end
end
