defmodule AuthorizationControl.Accounts.Tokens do
  use AuthorizationControl.Schema

  alias AuthorizationControl.Accounts.{Admin, User, Tokens}

  schema "tokens" do
    field(:send_to, :string)
    field(:token, :string)
    field(:context, Ecto.Enum, values: [:password_recovery, :email_confirmation])
    field(:confirmation_url, :string, virtual: true)
    belongs_to(:user, User)
    belongs_to(:admin, Admin)

    timestamps()
  end

  def build(%User{id: user_id}, send_to, context) do
    token = build_token(64)
    confirmation_url = "#{send_to}/#{token}"

    %Tokens{
      user_id: user_id,
      send_to: send_to,
      token: token,
      context: context,
      confirmation_url: confirmation_url
    }
  end

  def build(%Admin{id: admin_id}, send_to, context) do
    token = build_token(64)
    confirmation_url = "#{send_to}/#{token}"

    %Tokens{
      admin_id: admin_id,
      send_to: send_to,
      token: token,
      context: context,
      confirmation_url: confirmation_url
    }
  end

  def build_token(length) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
