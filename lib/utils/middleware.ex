defmodule Util.Middleware do
  @moduledoc """
  Module only middleware functions
  """

  @doc """
  Check if a schema params is ok

  Returns `{:ok, params} | {:error, binary}`

  ## Examples

      iex> params = %{b: "banana", c: nil}
      %{b: "banana", c: nil}
      iex> prepar(params)
      {:error, "c is unavailable"}

  """
  @doc since: "1.0.0"
  def prepar(params) do
    is_not_prepared = Map.to_list(params) |> List.keyfind(nil, 1)

    case present?(is_not_prepared) do
      true ->
        {param, _} = is_not_prepared
        {:error, Kernel.to_string(param) <> " is unavailable"}

      false ->
        filtred_params =
          Enum.reduce(params, %{}, fn {target, value}, filtred_params ->
            has_setted(value, filtred_params, target)
          end)

        {:ok, filtred_params}
    end
  end

  defp has_setted(:not_setted, filtered_params, _target), do: filtered_params
  defp has_setted(value, filtred_params, target), do: Map.put(filtred_params, target, value)

  def present?(nil), do: false
  def present?(false), do: false
  def present?(_), do: true
end
