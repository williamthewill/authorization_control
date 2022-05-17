defmodule AuthorizationControl.Accounts.AccountsNotifier do
  alias Utils.Email

  def send_url_confirmation(%{name: name, email: email}, url_confirmation) do
    Email.send(
      email,
      "Recuperação de senha",
      %{name: name, link: url_confirmation},
      "account_recover_password.html"
    )
  end

  def send_password_changed(%{name: name, email: email}) do
    Email.send(
      email,
      "Senha alterada com sucesso",
      %{name: name},
      "account_changed_password.html"
    )
  end

  def send_email_confirmation(%{name: name, email: email}, url_confirmation) do
    Email.send(
      email,
      "Confirmação de Email",
      %{name: name, link: url_confirmation},
      "account_email_confirmation.html"
    )
  end

  def send_welcome_message(%{name: name, email: email}) do
    Email.send(
      email,
      "Seja Bem Vindo ao Programa",
      %{name: name},
      "account_welcome.html"
    )
  end

  def send_account_updated(%{name: name, email: email}) do
    Email.send(
      email,
      "Sua conta foi atualizada",
      %{name: name},
      "account_updated.html"
    )
  end

  def send_toggle_active(%{name: name, email: email}, false) do
    do_send_toggle_active(name, email, "Atenção, sua conta foi desativada", false)
  end

  def send_toggle_active(%{name: name, email: email}, true) do
    do_send_toggle_active(name, email, "Atenção, sua conta foi ativada", true)
  end

  defp do_send_toggle_active(name, email, subject, is_active) do
    Email.send(
      email,
      subject,
      %{name: name, is_active: is_active},
      "account_toggle.html"
    )
  end
end
