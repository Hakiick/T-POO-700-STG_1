defmodule TimeManagerWeb.TeamsController do
  use TimeManagerWeb, :controller
  alias TimeManager.Accounts
  alias TimeManager.Accounts.Team
  action_fallback TimeManagerWeb.FallbackController

  def index(conn, _params) do
    teams = Accounts.list_teams()
    render(conn, "index.json", teams: teams)
  end

  def show(conn, %{"id" => id}) do
    try do
      team = Accounts.get_team!(id)
      render(conn, "show.json", team: team)
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Team not found"})
    end
  end

  def create(conn, %{"team" => team_params}) do
    with {:ok, %Team{} = team} <- Accounts.create_team(team_params) do
      conn
      |> put_status(:created)
      |> render("show.json", team: team)
    end
  end

  def update(conn, %{"id" => id, "team" => team_params}) do
    with {:ok, %Team{} = team} <- Accounts.update_team(id, team_params) do
      conn
      |> put_status(:ok)
      |> render("show.json", team: team)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %Team{} = team} <- Accounts.delete_team(id) do
      conn
      |> put_status(:no_content)
      |> json(%{})
    end
  end
end
