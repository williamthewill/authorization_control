defmodule AuthorizationControlWeb.LogController do
  use AuthorizationControlWeb, :controller

  alias AuthorizationControl.Logs

  action_fallback(AuthorizationControlWeb.FallbackController)

  def index(conn, params) do
    with params <- search_params(params),
         logs <- Logs.list_paginated(params) do
      conn
      |> put_status(:ok)
      |> render("index.json", logs: logs)
    end
  end

  defp search_params(params) do
    [
      page: params["page"],
      page_size: params["page_size"],
      change_agent: params["change_agent"] || "",
      message: params["message"] || "",
      start_date: params["start_date"] || "",
      end_date: params["end_date"] || ""
    ]
  end
end
