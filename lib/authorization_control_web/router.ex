defmodule AuthorizationControlWeb.Router do
  use AuthorizationControlWeb, :router

  import AuthorizationControlWeb.Auth

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth_admin do
    plug(AuthorizationControlWeb.Auth.Pipeline.Admin)
    plug(AuthorizationControlWeb.Plug.AdminAuthorization)
  end

  pipeline :session do
    plug(:session_pipe)
    plug(:fetch_session)
  end

  scope "/v1", AuthorizationControlWeb do
    pipe_through(:api)

    scope "/backoffice/session/clients" do
      post("/login", ClientController, :login_admin, as: :faz_login_backoffice)
      post("/password", ClientController, :change_password, as: :alterar_senha_backoffice)
      post("/recover-password", TokensController, :create, as: :recuperar_senha_backoffice)
      patch("/confirm-email/:token", TokensController, as: :confirmar_email_backoffice)
      patch("/recover-password/:token", TokensController, as: :confirmar_senha_backoffice)
    end

    # ADMIN Routes
    pipe_through(:auth_admin)

    scope "/backoffice" do
      scope "/session" do
        pipe_through(:session)

        get("/admins", ClientController, :index, as: :listar_administrador)
        get("/admins/:id", ClientController, :show, as: :detalhes_administrador)
        post("/admins", ClientController, :create, as: :criar_administrador)

        patch("/admins/confirm-email/:token", TokensController, :confirm_email,
          as: :confirmar_email_administrador
        )

        patch("/admins/:id", ClientController, :update_admin, as: :editar_administrador)

        patch("/admins/:id/toggle-is-active", ClientController, :toggle_is_active,
          as: :ativa_e_desativa_admin
        )

        get("/access/routes", RoutesController, :show, as: :listar_rotas_da_aplicação)

        get("/access/operations", OperationsController, :index, as: :listar_operações)
        get("/access/operations/:name", OperationsController, :show, as: :detalhes_de_operação)
        post("/access/operations", OperationsController, :create, as: :criar_operação)
        patch("/access/operations/:name", OperationsController, :update, as: :editar_operação)
      end

      get("/logs", LogController, :index, as: :listar_logs)
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: AuthorizationControlWeb.Telemetry
    end
  end
end
