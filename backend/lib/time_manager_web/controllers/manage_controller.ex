defmodule TimeManagerWeb.ManageController do
  use TimeManagerWeb, :controller

  alias TimeManager.Accounts
  alias TimeManager.Timesheet
  alias TimeManager.Accounts.Manage

  action_fallback TimeManagerWeb.FallbackController

  def index(conn, params) do
    manage = Accounts.get_manage!(params)
    render(conn, :index, manage: manage)
  end

  def create(conn, %{"userId" => user_id, "teamId" => team_id}) do
    manage_params = %{"user_id" => user_id, "team_id" => team_id}

    with {:ok, %Manage{} = manage} <- Accounts.create_manage(manage_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/manage/#{manage}")
      |> render(:show, manage: manage)
    end
  end

  def show(conn, %{"id" => id}) do
    manage = Accounts.get_manage!(%{"id" => id})
    render(conn, :show, manage: manage)
  end

  def update(conn, %{"id" => id, "userId" => user_id, "teamId" => team_id}) do
    manage = Accounts.get_manage!(id)
    manage_params = %{"user_id" => user_id, "team_id" => team_id}

    with {:ok, %Manage{} = manage} <- Accounts.update_manage(manage, manage_params) do
      render(conn, :show, manage: manage)
    end
  end

  def delete(conn, %{"userID" => user_id, "teamID" => team_id}) do
    user = Accounts.get_user!(%{"id" => user_id})
    team = Accounts.get_teams!(team_id)
    manage = Accounts.get_from_user_and_team(user, team)

    with {:ok, %Manage{}} <- Accounts.delete_manage(manage) do
      send_resp(conn, :no_content, "")
    end
  end

  def index_users_from_team(conn, %{"id" => id}) do
    team = Accounts.get_teams!(id)
    user = Guardian.Plug.current_resource(conn)

    if user.role != "general_manager" do
      if !Accounts.is_manager?(user, team) do
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You are not allowed to access this resource"})
      end
    end

    users = Accounts.get_users_from_team(team)
    render(conn, :index, users: users)
  end

  def index_teams_from_user(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    teams = Accounts.get_teams_from_user(user)
    render(conn, :index, teams: teams)
  end

  def clock_in_for_team(conn, %{"id" => id}) do
    team = Accounts.get_teams!(id)
    user = Guardian.Plug.current_resource(conn)

    if user.role != "general_manager" do
      if !Accounts.is_manager?(user, team) do
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You are not allowed to access this resource"})
      end
    end

    users = Accounts.get_users_from_team(team)

    for user <- users do
      Accounts.clock_in_if_last_clocked_out(user.id)
    end

    conn
    |> put_status(:ok)
    |> json(%{message: "clocked in for team"})
  end

  def clock_out_for_team(conn, %{"id" => id}) do
    team = Accounts.get_teams!(id)
    user = Guardian.Plug.current_resource(conn)

    if user.role != "general_manager" do
      if !Accounts.is_manager?(user, team) do
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You are not allowed to access this resource"})
      end
    end

    users = Accounts.get_users_from_team(team)

    for user <- users do
      Accounts.clock_out_if_last_clocked_out(user.id)
    end

    conn
    |> put_status(:ok)
    |> json(%{message: "clocked out for team"})
  end
end
