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

  pipeline :api_refresh do
    plug :accepts, ["json"]

    plug TimeManager.Accounts.MiddlewareRefresh
  end

  pipeline :api_protected do
    plug :accepts, ["json"]

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
    get "/users/reset_password/:token", UserResetPasswordController, :edit
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
    get "/users/all", UserController, :index
    get "/users/:userID", UserController, :show
    put "/users/:userID", UserController, :update
    delete "/users/:userID", UserController, :delete

    # WORKING TIME Routes
    get "/workingtime/:userID", WorkingTimeController, :index
    get "/workingtime/:userID/:id", WorkingTimeController, :show
    post "/workingtime/:userID", WorkingTimeController, :create
    put "/workingtime/:id", WorkingTimeController, :update
    delete "/workingtime/:id", WorkingTimeController, :delete

    # CLOCKING Routes
    get "/clock/:userID", ClockController, :show
    get "/clocks/:userID", ClockController, :index
    post "/clocks/:userID", ClockController, :create
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
