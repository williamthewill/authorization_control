defmodule AuthorizationControlWeb.Auth.Guardian do
  use Guardian, otp_app: :authorization_control

  alias AuthorizationControl.Accounts

  @primary_key_target 1
  @self_admin_path "[GET]/v1/backoffice/session/admins/:id"

  @doc since: "1.0.0"
  # defdelegate validate_pass(password, password_hash), to: Argon2, as: :verify_pass
  def validate_pass(password, password_hash) do
    IO.inspect(password)
    IO.inspect(password_hash)
    Argon2.verify_pass(password, password_hash) |> IO.inspect()
  end

  def subject_for_token(client, _claims) do
    {:ok, to_string(client.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    Accounts.get_user(id)
  end

  def authenticate(email, password) do
    IO.inspect("email==================")
    IO.inspect(email)
    IO.inspect(password)
    with {:ok, {acount, client}} <- AuthorizationControl.get_client_by_login(email),
         true <- validate_pass(password, client.password_hash) do
          IO.inspect("is_authenticate")
      {:ok, {acount, client}} |> IO.inspect()
    else
      {:error, _} -> {:error, "Invalid credentials"}
      _ -> {:error, "Invalid credentials"}
    end
  end

  def create_token(account, client) do
    is_admin = account == :admin

    with false <- is_admin && client.first_login,
         params <- get_token_params(account, client),
         {:ok, token, _claims} <-
           encode_and_sign(
             client,
             params,
             ttl: {8, :hours}
           ) do
            AuthorizationControl.update_client(
        client.id,
        %{access_token: token},
        AuthorizationControl.schema_by_account(account)
      )

      {:ok, token}
    else
      true -> {:error, "You need change the password", 1338}
      {:error, message} -> {:error, message}
    end
  end

  def get_token_params(account, client) do
    case account do
      :admin ->
        %{
          account: account,
          access_operations: client.operations,
          is_adam: client.is_adam
        }

      _ ->
        %{
          account: account
        }
    end
  end

  def verify_email(email) do
    case AuthorizationControl.get_client_by_login(email) do
      {:ok, {_account, %{confirmed_at: nil}}} ->
        {:error, "Email not confirmed", 1338}

      {:ok, {_account, %{confirmed_at: _confirmed_at}}} ->
        {:ok, true}

      _ ->
        {:error, "Invalid credentials"}
    end
  end

  def verify_authorization(
        %{private: %{guardian_default_claims: %{"is_adam" => true}}},
        :admin
      ),
      do: {:ok, true}

  @doc since: "1.0.0"
  def verify_authorization(
        %{
          params: params,
          private: %{
            guardian_default_claims: %{
              "access_operations" => access_operations
            }
          }
        } = conn,
        :admin
      ) do
        IO.inspect("authorization")
        IO.inspect(params)
        IO.inspect(access_operations)
    case Util.mount_path(conn) do
      @self_admin_path ->
        {:ok, true}

      request_path ->
        IO.inspect("request path")
        IO.inspect(request_path)
        actions = actions_from_path_operation!(request_path, access_operations)
        intersection_actions_params = Map.take(params, actions)
        IO.inspect("intersection_actions_params")
        IO.inspect(intersection_actions_params)
        IO.inspect("params")
        IO.inspect(params)
        {:ok, "full" in actions || map_size(intersection_actions_params) == map_size(params)}
        |> handle_response
    end
  end

  def verify_authorization(_conn, :admin), do: {:ok, true}

  def verify_authorization(%{request_path: request_path}, :user) do
    case String.contains?(request_path, "backoffice/session") do
      true -> {:error, "Not Authorized", 4003}
      _ -> {:ok, true}
    end
  end

  @doc since: "1.0.0"
  def verify_authorization(
        %{private: %{guardian_default_claims: %{"is_adam" => true}}},
        :admin,
        _
      ),
      do: {:ok, true}

  @doc """
  Verify authorization when only-self is hability
  """
  @doc since: "1.0.0"
  def verify_authorization(
        %{
          params: params,
          private: %{
            guardian_default_claims: %{
              "access_operations" => access_operations,
              "sub" => client_id
            }
          }
        } = conn,
        :admin,
        {:primary_key_target, primary_key_target}
      ) do
    request_path = Util.mount_path(conn)

    actions = actions_from_path_operation!(request_path, access_operations)

    intersection_actions_params = Map.take(params, actions)

    has_param_overflow? =
      !(map_size(intersection_actions_params) == map_size(params) - @primary_key_target)

    can_continue? =
      can_continue_by_only_self(
        only_self?(actions),
        client_id,
        params[Atom.to_string(primary_key_target)]
      )

    {:ok, !has_param_overflow? and can_continue?}
    |> handle_response
  end

  def verify_active(%{is_active: true}), do: {:ok, true} |> handle_response()
  def verify_active(%{is_active: false}), do: {:ok, false} |> handle_response()
  def verify_active(_), do: {:error, false} |> handle_response()

  defp actions_from_path_operation!(request_path, access_operations) do
    Map.keys(access_operations)
    |> Enum.reduce_while([], fn x, acc ->
      if acc == [] do
        {:cont, get_in(access_operations, [x, request_path])}
      else
        {:halt, acc}
      end
    end) ||
      []
  end

  defp only_self?(actions) do
    Enum.member?(actions, "only-self")
  end

  defp can_continue_by_only_self(false, _client_id, _client_id_param), do: true

  defp can_continue_by_only_self(true, client_id, client_id_param),
    do: client_id == client_id_param

  defp handle_response({:ok, false}) do
    {:error, "Not Authorized", 4003}
  end

  defp handle_response(response), do: response
end
