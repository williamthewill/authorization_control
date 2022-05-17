defmodule AuthorizationControl do
  @moduledoc """
  AuthorizationControl keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias AuthorizationControlWeb.{ClientController, PatternMessage}
  alias Utils.Crud.{Get, GetBy, Update}

    # ----------------------------------------------- Clients methods -------------------------------
  # ► GET
  defdelegate get_client_by_login(email),
    to: ClientController,
    as: :identify_client

  defdelegate get_client(client_id, schema),
    to: Get,
    as: :call

  defdelegate get_client_by(params, schema),
    to: GetBy,
    as: :call

  defdelegate update_client(primary_key, params, schema, name \\ "Client"),
    to: Update,
    as: :call

  defdelegate schema_by_account(account), to: AuthorizationControl.Accounts.Client, as: :schema_by_account

  # ----------------------------------------------- Message methods -------------------------------
  # ► Message
  defdelegate get_message(name), to: PatternMessage, as: :call
end
