defmodule Util do
  @moduledoc """
  Util keeps the context of the modules that are helpers to other modules.
  """

  @doc """
  Method to convert strings of booleans into booleans or strings of integers into integers
  """
  def convert!("true"), do: true
  def convert!("false"), do: false
  def convert!(nil), do: nil
  def convert!(""), do: nil
  def convert!(bool) when is_boolean(bool), do: bool
  def convert!(num), do: String.to_integer(num)

  def mount_path(conn) do
    path_with_values = "[#{conn.method}]/#{Enum.join(conn.path_info, "/")}"

    conn.path_params
    |> Enum.reduce(path_with_values, fn {target, value}, pwv ->
      String.replace(pwv, value, ":#{target}")
    end)
  end
end
