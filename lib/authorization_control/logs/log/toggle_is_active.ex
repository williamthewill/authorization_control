defmodule AuthorizationControl.Logs.Log.ToggleIsActive do
  alias AuthorizationControl.{Accounts}
  alias AuthorizationControl.Logs.Log

  def build(%Accounts.Admin{id: id} = change_agent, target_agent, params) do
    %Log{
      change_agent: id,
      message: build_message(change_agent, target_agent, params),
      metadata: build_metadata(target_agent, params)
    }
  end

  # def build(_change_agent, target_agent, params) do
  #   %Log{
  #     change_agent: nil,
  #     message: build_message(nil, target_agent, params),
  #     metadata: build_metadata(target_agent, params)
  #   }
  # end

  defp build_message(change_agent, target_agent, true),
    do: ~s(O administrador "#{change_agent.email}" ativou #{target(target_agent)})

  defp build_message(change_agent, target_agent, false),
    do: ~s(O administrador "#{change_agent.email}" desativou #{target(target_agent)})

  defp target(%Accounts.User{external_load_id: external_load_id}),
    do: ~s(o usuário com o external load id "#{external_load_id}")

  defp target(%Accounts.Admin{email: email}), do: ~s(o administrador com o email "#{email}")

  defp build_metadata(%Accounts.User{} = target, params),
    do: %{
      "target" => %{"type" => "users", "id" => target.id},
      "params" => %{"is_active" => params}
    }

  defp build_metadata(%Accounts.Admin{} = target, params),
    do: %{
      "target" => %{"type" => "admins", "id" => target.id},
      "params" => %{"is_active" => params}
    }
end
