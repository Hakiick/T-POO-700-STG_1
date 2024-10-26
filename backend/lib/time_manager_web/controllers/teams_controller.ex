defmodule TimeManagerWeb.TeamsController do
  use TimeManagerWeb, :controller

  alias TimeManager.Accounts
  alias TimeManager.Accounts.Teams

  action_fallback TimeManagerWeb.FallbackController

  def index(conn, _params) do
    teams = Accounts.list_teams()
    render(conn, :index, teams: teams)
  end

  def create(conn, %{"teams" => teams_params}) do
    with {:ok, %Teams{} = teams} <- Accounts.create_teams(teams_params) do
      conn
      |> put_status(:created)
      # |> put_resp_header("location", ~p"/api/teams/#{teams}")
      |> render(:show, teams: teams)
    end
  end

  def show(conn, %{"id" => id}) do
    teams = Accounts.get_teams!(id)
    render(conn, :show, teams: teams)
  end

  def update(conn, %{"id" => id, "teams" => teams_params}) do
    teams = Accounts.get_teams!(id)

    with {:ok, %Teams{} = teams} <- Accounts.update_teams(teams, teams_params) do
      render(conn, :show, teams: teams)
    end
  end

  def delete(conn, %{"id" => id}) do
    teams = Accounts.get_teams!(id)

    with {:ok, %Teams{}} <- Accounts.delete_teams(teams) do
      send_resp(conn, :no_content, "")
    end
  end
end
