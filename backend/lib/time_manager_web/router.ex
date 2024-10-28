defmodule TimeManagerWeb.Router do
  use TimeManagerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug :accepts, ["json"]
    # Apply JWT middleware to protect routes
    plug Guardian.Plug.Pipeline,
      module: TimeManager.Guardian,
      error_handler: TimeManagerWeb.AuthErrorHandler
  end

  pipeline :manager_access do
    plug :accepts, ["json"]
    plug TimeManagerWeb.Plugs.RolePlug, roles: ["manager", "general_manager"]
  end

  pipeline :general_manager_access do
    plug :accepts, ["json"]
    plug TimeManagerWeb.Plugs.RolePlug, roles: ["general_manager"]
  end

  pipeline :managed_access do
    plug :accepts, ["json"]
    plug TimeManagerWeb.Plugs.AuthorizeUserManaged
  end

  pipeline :api_refresh do
    plug :accepts, ["json"]

    plug TimeManager.Accounts.MiddlewareRefresh
  end

  pipeline :api_protected do
    plug :accepts, ["json"]

    plug TimeManager.Accounts.Middleware
    plug TimeManager.Accounts.Middleware
  end

  scope "/api", TimeManagerWeb do
    pipe_through :api_auth

    # USER Routes
    # get "/users", UserController, :show_from_mail_and_username
    # get "/users/:userID", UserController, :show
    # post "/users", UserController, :create
    # put "/users/:userID", UserController, :update
    # delete "/users/:userID", UserController, :delete

    post "/users/register", UserRegistrationController, :create
    get "/users/confirm/:token", UserRegistrationController, :confirm
    post "/users/login", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/api", TimeManagerWeb do
    # Protected routes require valid JWT
    pipe_through :api_refresh
    get "/users/refresh", UserSessionController, :refresh
  end

  scope "/api", TimeManagerWeb do
    # Protected routes require valid JWT
    pipe_through :api_protected

    # USER Routes (protected)
    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    # post "/users/refresh", UserSessionController, :refresh

    get "/user", UserController, :get_from_jwt
    get "/users", UserController, :show_from_mail_and_username
    get "/users/:userID", UserController, :show

    scope "/workingtime" do
      pipe_through :managed_access
      # WORKING TIME Routes
      get "/:userID", WorkingTimeController, :index
      get "/:userID/:id", WorkingTimeController, :show
      post "/:userID", WorkingTimeController, :create
      put "/:id", WorkingTimeController, :update
      delete "/:id", WorkingTimeController, :delete
    end

    # CLOCKING Routes
    scope "/clocks" do
      pipe_through :managed_access

      get "/:userID", ClockController, :show
      get "/:userID", ClockController, :index
      post "/:userID", ClockController, :create
    end

    scope "/admin" do
      pipe_through :manager_access

      put "/users/:userID", UserController, :update
      delete "/users/:userID", UserController, :delete

      post "/users", UserRegistrationController, :create_by_manager

      get "/teams/:id/clock_in", ManageController, :clock_in_for_team
      get "/teams/:id/clock_out", ManageController, :clock_out_for_team

      get "/teams/:id/users", ManageController, :index_users_from_team
      get "/users/teams", ManageController, :index_teams_from_user
      post "/manage", ManageController, :create
      delete "/manage/:userID/:teamID", ManageController, :delete

      scope "/gestion" do
        pipe_through :general_manager_access

        get "/users/all", UserController, :index

        get "/teams", TeamsController, :index
        post "/teams", TeamsController, :create
        put "/teams/:id", TeamsController, :update
        delete "/teams/:id", TeamsController, :delete

        get "/promote_to_manager/:userID", UserController, :update_role_to_manager
        get "/demote_to_user/:userID", UserController, :update_role_to_user
      end
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: TimeManagerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
