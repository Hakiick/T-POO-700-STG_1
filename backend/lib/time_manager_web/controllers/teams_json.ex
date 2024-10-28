defmodule TimeManagerWeb.TeamsJSON do
  alias TimeManager.Accounts.Teams

  @doc """
  Renders a list of teams.
  """
  def index(%{teams: teams}) do
    %{data: for(teams <- teams, do: data(teams))}
  end

  @doc """
  Renders a single teams.
  """
  def show(%{teams: teams}) do
    %{data: data(teams)}
  end

  defp data(%Teams{} = teams) do
    %{
      id: teams.id,
      name: teams.name,
      description: teams.description
    }
  end
end
