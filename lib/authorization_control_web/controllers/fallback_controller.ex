defmodule AuthorizationControlWeb.FallbackController do
  use AuthorizationControlWeb, :controller

  alias AuthorizationControlWeb.ErrorHelpers
  alias AuthorizationControl.Accounts.{Admin, User}

  def call(conn, {:error, :ledger_not_found}) do
    conn
    |> put_status(:bad_request)
    |> put_view(AuthorizationControlWeb.ErrorView)
    |> render("400.json",
      code: 4001,
      message: "user not found"
    )
  end

  def call(conn, pau) do
    IO.inspect(pau)
    conn
    |> put_status(:bad_request)
    |> put_view(AuthorizationControlWeb.ErrorView)
    |> render("400.json",
      code: 4001,
      message: "deu ruim"
    )
  end

  def call(conn, {:error, :insufficient_amount_to_reverse, points}) do
    conn
    |> put_status(:bad_request)
    |> put_view(AuthorizationControlWeb.ErrorView)
    |> render("400.json",
      code: 6003,
      message: "the user not has #{points} points to reverse"
    )
  end

  def call(conn, {:error, :provider_rule_should_be_cash_out}) do
    conn
    |> put_status(:bad_request)
    |> put_view(AuthorizationControlWeb.ErrorView)
    |> render("400.json",
      code: 3002,
      message: "provider rule type should be cash out"
    )
  end

  def call(conn, {:error, :invalid_reverse_points}) do
    conn
    |> put_status(:bad_request)
    |> put_view(AuthorizationControlWeb.ErrorView)
    |> render("400.json",
      code: 6004,
      message: "invalid points to reverse"
    )
  end

  def call(conn, {:error, :invalid_min_points}) do
    conn
    |> put_status(:bad_request)
    |> put_view(AuthorizationControlWeb.ErrorView)
    |> render("400.json",
      code: 6002,
      message: "the points to redeem can't less than 0"
    )
  end

  def call(conn, {:error, :user_not_found}) do
    conn
    |> put_status(:bad_request)
    |> put_view(AuthorizationControlWeb.ErrorView)
    |> render("400.json",
      code: 4001,
      message: "user not found"
    )
  end

  def call(conn, {:error, "Invalid credentials"}) do
    conn
    |> put_status(:bad_request)
    |> put_view(AuthorizationControlWeb.ErrorView)
    |> render("400.json",
      code: 4002,
      message: "invalid credentials"
    )
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:bad_request)
    |> put_view(AuthorizationControlWeb.ErrorView)
    |> render("400.json", changeset: changeset)
  end

  def call(conn, {:error, nil}) do
    conn
    |> put_status(:not_found)
    |> put_view(AuthorizationControlWeb.ErrorView)
    |> render("404.json", nil)
  end

  def call(conn, {:error, _reason} = error) do
    conn
    |> put_status(:bad_request)
    |> put_view(AuthorizationControlWeb.ErrorView)
    |> render("400.json", ErrorHelpers.build_error_parameters(error))
  end

  def call(conn, {:error, message, code}) do
    conn
    |> put_status(:bad_request)
    |> put_view(AuthorizationControlWeb.ErrorView)
    |> render("400.json", code: code, message: message)
  end

  def call(conn, {:ok, {:admin, %Admin{}}}) do
    conn
    |> put_status(:bad_request)
    |> put_view(AuthorizationControlWeb.ErrorView)
    |> render("400.json",
      code: 4002,
      message: "invalid credentials"
    )
  end

  def call(conn, {:ok, {:user, %User{}}}) do
    conn
    |> put_status(:bad_request)
    |> put_view(AuthorizationControlWeb.ErrorView)
    |> render("400.json",
      code: 4002,
      message: "invalid credentials"
    )
  end
end
