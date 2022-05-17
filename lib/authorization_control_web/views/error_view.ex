defmodule AuthorizationControlWeb.ErrorView do
  use AuthorizationControlWeb, :view

  alias AuthorizationControlWeb.ErrorHelpers

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

  def render("400.json", %{changeset: changeset}) do
    IO.inspect("400 chageset")
    error =
      changeset
      |> format_to_response()
      |> group_by_code()

    %{error: error}
  end

  def render("400.json", %{code: code, message: message}) do
    IO.inspect("400 with code #{code}")
    %{
      error: [
        %{
          code: code,
          message: message,
          fields: []
        }
      ]
    }
  end

  def render("401.json", %{error: error}) do
    %{error: error}
  end

  def render("400.json", %{result: %Ecto.Changeset{} = result}) do
    %{error: ErrorHelpers.translate_errors(result)}
  end

  # TODO bateu aqui
  def render("400.json", %{error: error}) do
    IO.inspect("render 400")
    %{error: "banana"}
  end

  def render("404.json", _value) do
    %{error: "Not Found"}
  end
end
