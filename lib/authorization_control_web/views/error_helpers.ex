defmodule AuthorizationControlWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  import Ecto.Changeset, only: [traverse_errors: 2]

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:span, translate_error(error),
        class: "invalid-feedback",
        phx_feedback_for: input_name(form, field)
      )
    end)
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(AuthorizationControlWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(AuthorizationControlWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates errors message from the changeset.
  """
  def translate_errors(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def build_error_parameters({:error, :ledger_not_found}, external_load_id),
    do: %{code: 4001, message: "User not found", externalLoadId: external_load_id}

  def build_error_parameters({:error, :provider_not_found}, external_load_id),
    do: %{code: 2001, message: "provider not found", externalLoadId: external_load_id}

  def build_error_parameters({:error, :provider_rule_not_found}, external_load_id),
    do: %{code: 3001, message: "provider rule not found", externalLoadId: external_load_id}

  def build_error_parameters({:error, :provider_rule_should_be_cash_out}, external_load_id),
    do: %{
      code: 3002,
      message: "provider rule type should be cash out",
      externalLoadId: external_load_id
    }

  def build_error_parameters({:error, :provider_rule_should_be_cash_in}, external_load_id),
    do: %{
      code: 3002,
      message: "provider rule type should be cash in",
      externalLoadId: external_load_id
    }

  def build_error_parameters({:error, :there_are_not_anough_points}, external_load_id),
    do: %{
      code: 6001,
      message: "the user wallet there are not anough points to redeem",
      externalLoadId: external_load_id
    }

  def build_error_parameters({:error, :invalid_min_points}, external_load_id),
    do: %{
      code: 6002,
      message: "the points can't less than 0",
      externalLoadId: external_load_id
    }

  def build_error_parameters({:error, message}, external_load_id),
    do: %{code: 1001, message: message, externalLoadId: external_load_id}

  def build_error_parameters({:error, :there_are_not_anough_points}),
    do: %{
      code: 6001,
      message: "the user wallet there are not anough points to redeem"
    }

  def build_error_parameters({:error, :invalid_min_points}),
    do: %{
      code: 6002,
      message: "the points can't less than 0"
    }

  def build_error_parameters({:error, :invalid_rescue_amount}),
    do: %{
      code: 6003,
      message: "the rescue amount is invalid"
    }

  # TODO bateu aqui
  def build_error_parameters({:error, message}) do
    IO.inspect("build error parameters message")
    IO.inspect(message)
    %{code: 1001, message: message}
  end

  @doc false
  def format_to_response(%Ecto.Changeset{errors: errors} = _changeset) do
    Enum.map(errors, fn {field, {_reason, details}} ->
      Enum.reduce(details, [], handle_type_error(field))
    end)
  end

  # parse changeset error to response format
  defp handle_type_error(field) do
    fn
      {:validation, :required}, _response ->
        %{
          code: 1001,
          message: "required params is missing",
          fields: [field]
        }

      {:validation, :length}, _response ->
        %{
          code: 1002,
          message: "invalid params size",
          fields: [field]
        }

      {:constraint, :unique}, _response ->
        %{
          code: 1003,
          message: "not unique params",
          fields: [field]
        }

      {:validation, :cast}, _response ->
        %{
          code: 1004,
          message: "invalide type",
          fields: [field]
        }

      {:validation, :format}, _response ->
        %{
          code: 1005,
          message: "invalid format",
          fields: []
        }

      {:validation, :confirmation}, _response ->
        %{
          code: 1006,
          message: "does not match confirmation",
          fields: []
        }

      {:validation, :transaction_info}, _response ->
        %{
          code: 1301,
          message: "transaction info is not valid",
          fields: [field]
        }

      {:not_found, :provider_code}, _response ->
        %{
          code: 2001,
          message: "provider not found",
          fields: []
        }

      {:amount, :points}, _response ->
        %{
          code: 5001,
          message: "the points calculation result can't less or equal then 0",
          fields: []
        }

      _, response ->
        response
    end
  end

  @doc false
  def group_by_code(errors) do
    errors
    |> Enum.group_by(fn %{code: code} = _map -> code end)
    |> Enum.map(fn {_, list} -> Enum.reduce(list, &group_fields/2) end)
  end

  defp group_fields(%{fields: fields} = _item, acc) do
    fields = Enum.map(fields, &format_field/1)
    %{acc | fields: acc.fields ++ fields}
  end

  defp format_field(field) do
    field
    |> Atom.to_string()
    |> String.replace("_", "")
  end
end
