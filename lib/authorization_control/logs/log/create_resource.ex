defmodule AuthorizationControl.Logs.Log.CreateResource do
  alias AuthorizationControl.{Accounts, Access}
  alias AuthorizationControl.Logs.Log

  def build(%Accounts.Admin{id: change_agent_id} = change_agent, resource, params) do
    %Log{
      change_agent: change_agent_id,
      message: build_message(change_agent, resource),
      metadata: build_metadata(resource, params)
    }
  end

  defp build_message(change_agent, %Accounts.Admin{} = resource),
    do:
      ~s(O administrador "#{change_agent.email}" cadastrou um novo administrador com o email #{
        resource.email
      })

  defp build_message(change_agent, %Access.Operations.Operation{} = resource),
    do:
      ~s(O administrador "#{change_agent.email}" cadastrou uma nova operação de nome #{
        resource.name
      })

  defp build_metadata(%Accounts.Admin{id: id}, params),
    do: %{"params" => params, "target" => %{"id" => id, "type" => "admins"}}


  defp build_metadata(%Access.Operations.Operation{name: name}, params),
    do: %{"params" => params, "target" => %{"name" => name, "type" => "operations"}}
end
