if Application.get_env(:authorization_control, :environment) != :test do
  alias AuthorizationControl.Accounts.{Admin, User}
  alias AuthorizationControl.Access.Operations.Operation
  alias AuthorizationControl.Access.Routes.Route
  alias AuthorizationControl.Providers
  alias AuthorizationControl.Repo
  alias AuthorizationControl.Providers.FaceInfo
  alias AuthorizationControl.Transactions.Ledger

  # Current date
  current_date =
    NaiveDateTime.utc_now()
    |> NaiveDateTime.truncate(:second)

  # Create Adam

  # password: alterar123
  adam = %Admin{
    email: "authorization_control@teste.com.br",
    password_hash:
      "$argon2id$v=19$m=131072,t=8,p=4$feZ35hZM3HSQmy2bf3x6VQ$PxtPhT1Kgiv+fTVWRBVrwdWV918ny4GkuDMYV2WEfp4",
    name: "authorization control teste",
    is_adam: true,
    access_operations: [],
    confirmed_at: current_date
  }

  Repo.insert!(adam, on_conflict: :nothing)

  # Create Access routes
  Repo.insert!(
    %Route{
      path: "[POST]/v1/backoffice/clients/password",
      message: "alterar_senha_path",
      actions: ["full", "only-self"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/providers",
      message: "listar_provedores_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/providers/:code",
      message: "lista_detalhes_provedor_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/providers/rules/:code",
      message: "lista_detalhes_regra_de_provedor_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/providers/:code/rules",
      message: "lista_regras_de_um_provedor_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[POST]/v1/transactions",
      message: "publicar_transações_de_usuários_rota_publica_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/users",
      message: "listar_usuarios_rota_publica_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/users/:external_load_id",
      message: "buscar_usuario_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/backoffice/providers",
      message: "listar_provedores_rota_publica_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/backoffice/provider/rules",
      message: "listar_regras_de_provedor_rota_publica_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[POST]/v1/backoffice/clients/password",
      message: "alterar_senha_rota_publica_path",
      actions: ["full", "only-self"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/backoffice/vouchers",
      message: "listar_vouchers_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[PATCH]/v1/backoffice/transactions/:external_load_id/reverse-points",
      message: "transaction_path",
      actions: ["full", "only-self", "points"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[PUT]/v1/backoffice/users/:id",
      message: "editar_usuario_path",
      actions: ["full", "only-self", "email", "name", "phone"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[PATCH]/v1/backoffice/users/:id/toggle-is-active",
      message: "ativa_e_desativa_usuario_path",
      actions: ["full", "only-self"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[POST]/v1/backoffice/session/providers",
      message: "criar_novo_provedor_path",
      actions: ["full", "code", "name", "description", "type"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[PUT]/v1/backoffice/session/providers/:id",
      message: "editar_provedor_path",
      actions: ["full", "code", "name", "description", "type", "isActive"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[PATCH]/v1/backoffice/session/providers/:id/toggle-is-active",
      message: "ativa_e_desativa_provedor_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[PATCH]/v1/backoffice/session/providers/:id/upload-image",
      message: "upload_de_imagem_de_provedor_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[POST]/v1/backoffice/session/providers/:id/rules",
      message: "cria_regra_de_provedor_path",
      actions: ["full", "name", "description", "code", "providerCode", "transactionInfo"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[PUT]/v1/backoffice/session/providers/rules/:id",
      message: "edita_regra_de_provedor_path",
      actions: [
        "full",
        "name",
        "description",
        "code",
        "providerCode",
        "transactionInfo",
        "seasonalValidity"
      ]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[PATCH]/v1/backoffice/session/providers/rules/:code/toggle-is-active",
      message: "ativa_e_desativa_regra_de_provedor_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[PATCH]/v1/backoffice/session/providers/rules/:id/upload-image",
      message: "upload_de_image_de_regra_de_provedor_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/backoffice/session/users/:external_load_id/wallet/details",
      message: "detalhes_carteira_usuario_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/backoffice/session/codes",
      message: "listar_codigo_de_provedores_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/backoffice/session/rules/codes",
      message: "listar_codigo_de_regras_de_provedor_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/backoffice/session/admins",
      message: "listar_administrador_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/backoffice/session/admins/:id",
      message: "detalhes_administrador",
      actions: ["full", "only-self"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[PATCH]/v1/backoffice/session/admins/:id",
      message: "editar_administrador_path",
      actions: ["full", "only-self", "email", "password", "name", "is_active", "operations"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/backoffice/logs",
      message: "listar_logs_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[PATCH]/v1/backoffice/session/admins/:id/toggle-is-active",
      message: "ativa_e_desativa_admin_path",
      actions: ["full", "only-self"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/backoffice/session/access/routes",
      message: "listar_rotas_da_aplicação_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/backoffice/session/access/operations",
      message: "listar_operações_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[GET]/v1/backoffice/session/access/operations/:name",
      message: "detalhes_de_operação_path",
      actions: ["full"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[POST]/v1/backoffice/session/access/operations",
      message: "criar_operação_path",
      actions: ["full", "name", "actionRoutes"]
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Route{
      path: "[PATCH]/v1/backoffice/session/access/operations/:name",
      message: "criar_operação_path",
      actions: ["full", "name", "actionsRoutes"]
    },
    on_conflict: :nothing
  )

  # Create Operation
  Repo.insert!(
    %Operation{
      name: "operation_test_one",
      actions_routes: %{
        "[PATCH]/v1/backoffice/session/admins/:id": ["only-self", "email", "password", "name"]
      }
    },
    on_conflict: :nothing
  )

  Repo.insert!(
    %Operation{
      name: "operation_test_two",
      actions_routes: %{
        "[GET]/v1/backoffice/session/providers": ["full"]
      }
    },
    on_conflict: :nothing
  )

  # Create Admin

  # password: alterar123
  Repo.insert!(
    %Admin{
      email: "admin@teste.com.br",
      password_hash:
        "$argon2id$v=19$m=131072,t=8,p=4$feZ35hZM3HSQmy2bf3x6VQ$PxtPhT1Kgiv+fTVWRBVrwdWV918ny4GkuDMYV2WEfp4",
      name: "admin teste",
      access_operations: ["operation_test_one", "operation_test_two"],
      confirmed_at: current_date
    },
    on_conflict: :nothing
  )

  # Create User
  user =
    %User{
      external_load_id: "85880529037",
      email: "user@email.com",
      password_hash:
        "$argon2id$v=19$m=131072,t=8,p=4$feZ35hZM3HSQmy2bf3x6VQ$PxtPhT1Kgiv+fTVWRBVrwdWV918ny4GkuDMYV2WEfp4",
      name: "user teste",
      cpf: "85880529037",
      phone: "48984506823",
      confirmed_at: current_date
    }
    |> Repo.insert!(on_conflict: :nothing)
end
