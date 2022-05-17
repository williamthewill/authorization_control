defmodule AuthorizationControl.Accounts do
  import Ecto.Query

  alias Helpers.Pagination
  alias AuthorizationControl.{Logs, Repo}
  alias AuthorizationControl.Accounts.{Admin, User, Searchs, Tokens}
  # alias AuthorizationControl.Accounts.AccountsNotifier

  @reset_password_validity_in_days 1

  def list_users(criteria) when is_list(criteria) do
    Searchs.Users.execute(criteria)
  end

  def get_user!(id), do: Repo.get(User, id)

  def get_user(criteria) when is_list(criteria) do
    case Repo.get_by(User, criteria) do
      nil ->
        {:error, :user_not_found}

      user ->
        {:ok, user}
    end
  end

  def get_user(id) do
    case Repo.get(User, id) do
      nil ->
        {:error, :user_not_found}

      user ->
        {:ok, user}
    end
  end

  def get_user_by_token(token) do
    token
    |> query_get_user_by_token(:password_recovery)
    |> where([token], token.inserted_at > ago(^@reset_password_validity_in_days, "day"))
    |> Repo.one()
    |> case do
      %{user: user} when not is_nil(user) ->
        {:ok, user}

      %{admin: admin} when not is_nil(admin) ->
        {:ok, admin}

      _ ->
        {:error, :user_not_found}
    end
  end

  def get_token(token) do
    token
    |> query_get_user_by_token(:email_confirmation)
    |> Repo.one()
    |> case do
      nil -> {:error, :user_not_found}
      token -> {:ok, token}
    end
  end

  defp query_get_user_by_token(token, context) do
    from(t in Tokens,
      left_join: u in User,
      on: t.user_id == u.id,
      left_join: a in Admin,
      on: t.admin_id == a.id,
      where: t.token == ^token,
      where: t.context == ^context,
      preload: [:admin, :user]
    )
  end

  def update_user(%User{} = user, attrs \\ %{}, opts \\ []),
    do: do_update_account(User, user, attrs, opts)

  def update_admin(%Admin{} = admin, attrs \\ %{}, opts \\ []),
    do: do_update_account(Admin, admin, attrs, opts)

  defp do_update_account(account_type, account, attrs, opts) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, account_type.update_changeset(account, attrs))
    |> Ecto.Multi.run(:updated_account, fn _repo, _email ->
      IO.inspect("send mail message")
      {:ok, true}
      # AccountsNotifier.send_account_updated(account)
    end)
    |> insert_log_update(attrs, opts)
    |> Repo.transaction()
    |> case do
      {:ok, %{account: account}} ->
        {:ok, account}

      {:error, _step, reason, _processed} ->
        {:error, reason}
    end
  end

  def toggle_user_is_active(%User{is_active: is_active} = user, opts \\ []),
    do: do_toggle_account(User, user, !is_active, opts)

  def toggle_admin_is_active(%Admin{is_active: is_active} = admin, opts \\ []),
    do: do_toggle_account(Admin, admin, !is_active, opts)

  defp do_toggle_account(account_type, account, is_active, opts) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, account_type.put_is_active(account, is_active))
    |> Ecto.Multi.run(:log, fn _, _ ->
      opts
      |> Keyword.get(:change_agent)
      |> Logs.toggle_is_active(account, is_active)
    end)
    |> Ecto.Multi.run(:updated_account, fn _repo, _email ->
      IO.inspect("send mail message")
      # AccountsNotifier.send_toggle_active(account, is_active)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{account: account}} ->
        {:ok, account}

      {:error, _step, reason, _processed} ->
        {:error, reason}
    end
  end

  def list_admins(criteria, search_param) when is_list(criteria) do
    complete_search_param = "%" <> search_param <> "%"

    from(adm in Admin,
      where:
        ilike(adm.name, ^complete_search_param) or
          ilike(adm.email, ^complete_search_param)
    )
    |> Pagination.paginate_query(criteria)
  end

  def list_admins(criteria) when is_list(criteria) do
    Pagination.paginate_query(Admin, criteria)
  end

  def get_admin(id) do
    case Repo.get(Admin, id) do
      nil ->
        {:error, :admin_not_found}

      admin ->
        {:ok, admin}
    end
  end

  def create_admin(send_to, attrs \\ %{}, opts \\ []),
    do: do_create_account(Admin, send_to, attrs, opts)

  def create_user(send_to, attrs \\ %{}, opts \\ []),
    do: do_create_account(User, send_to, attrs, opts)

  defp do_create_account(account, send_to, attrs, opts) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:account, account.changeset(attrs))
    |> Ecto.Multi.insert(:tokens, fn %{account: new_account} ->
      Tokens.build(new_account, send_to, :email_confirmation)
    end)
    |> Ecto.Multi.run(:confirm_email, fn _, %{account: _new_account, tokens: _tokens} ->
      IO.inspect("send mail message")
      # AccountsNotifier.send_email_confirmation(new_account, tokens.confirmation_url)
    end)
    |> insert_log(attrs, opts)
    |> Repo.transaction()
    |> case do
      {:ok, %{account: account}} ->
        {:ok, account}

      {:error, _step, reason, _processed} ->
        {:error, reason}
    end
  end

  defp insert_log(multi, attrs, opts) do
    if change_agent = Keyword.get(opts, :change_agent) do
      Ecto.Multi.run(multi, :log, fn _, %{account: account} ->
        Logs.create_resource(change_agent, account, attrs)
      end)
    else
      multi
    end
  end

  defp insert_log_update(multi, attrs, opts) do
    if change_agent = Keyword.get(opts, :change_agent) do
      Ecto.Multi.run(multi, :log, fn _, %{account: account} ->
        Logs.edit_resource(change_agent, account, attrs)
      end)
    else
      multi
    end
  end

  def recover_password(%{email: _email} = account, send_to)
      when is_bitstring(send_to) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:tokens, Tokens.build(account, send_to, :password_recovery))
    |> Ecto.Multi.run(:send_url_confirmation, fn _repo, %{tokens: _tokens} ->
      IO.inspect("send mail message")
      # AccountsNotifier.send_url_confirmation(account, tokens.confirmation_url)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{tokens: tokens}} ->
        {:ok, tokens}

      {:error, _step, reason, _processed} ->
        {:error, reason}
    end
  end

  def confirm_email(%Tokens{user: user}) when not is_nil(user),
    do: do_confirm_email(User, user)

  def confirm_email(%Tokens{admin: admin}) when not is_nil(admin),
    do: do_confirm_email(Admin, admin)

  defp do_confirm_email(account_schema, account) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, account_schema.confirm_email(account))
    |> Ecto.Multi.run(:welcome_message, fn _repo, _email ->
      # AccountsNotifier.send_welcome_message(account)
      IO.inspect("send mail message")
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{account: account}} ->
        {:ok, account}

      {:error, _step, reason, _processed} ->
        {:error, reason}
    end
  end

  def change_password(client, params \\ %{})

  def change_password(%User{id: user_id} = user, params) do
    query =
      from(at in Tokens,
        where: at.user_id == ^user_id
      )

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.change_password(user, params))
    |> Ecto.Multi.delete_all(:user_password_request, query)
    |> Ecto.Multi.run(:notify, fn _, _email ->
      IO.inspect("send mail message")
      # AccountsNotifier.send_password_changed(user)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, _step, reason, _processed} ->
        {:error, reason}
    end
  end

  def change_password(%Admin{} = admin, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:admin, Admin.change_password(admin, params))
    |> Ecto.Multi.run(:notify, fn _, _email ->
      IO.inspect("send mail message")
      {:ok, true}
      # AccountsNotifier.send_password_changed(admin)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{admin: admin}} -> {:ok, admin}
      {:error, _step, reason, _processed} -> {:error, reason}
    end
  end
end
