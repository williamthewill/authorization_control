defmodule AuthorizationControlWeb.LogView do
  use AuthorizationControlWeb, :view

  alias AuthorizationControl.Logs.Log

  def render("index.json", %{
        logs: %{data: logs, paging: paging}
      }) do
    %{
      logs: render_many(logs, __MODULE__, "log.json", as: :log),
      paging: paging
    }
  end

  def render("log.json", %{
        log: %Log{
          id: id,
          message: message,
          metadata: metadata,
          change_agent: change_agent,
          inserted_at: inserted_at
        }
      }) do
    %{
      id: id,
      message: message,
      metadata: metadata,
      change_agent: change_agent,
      inserted_at: inserted_at
    }
  end
end
