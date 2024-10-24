defmodule TimeManagerWeb.Router do
  use TimeManagerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TimeManagerWeb do
    pipe_through :api

    # USER Routes
    get "/users", UserController, :show_from_mail_and_username
    get "/users/all", UserController, :index
    get "/users/:userID", UserController, :show
    post "/users", UserController, :create
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

    get "/teams", TeamsController, :index
    post "/teams", TeamsController, :create
    put "/teams/:id", TeamsController, :update
    delete "/teams/:id", TeamsController, :delete

    get "/teams/:id/users", ManageController, :index_users_from_team
    get "/users/:id/teams", ManageController, :index_teams_from_user
    post "/manage", ManageController, :create
    delete "/manage/:userID/:teamID", ManageController, :delete
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
