defmodule TimeManagerWeb.TeamsJSON do
  alias TimeManager.Accounts.Team

  @doc """
  Renders a list of teams.
  """
  def index(%{teams: teams}) do
    %{data: for(team <- teams, do: data(team))}
  end

  @doc """
  Renders a single team.
  """
  def show(%{team: team}) do
    %{data: data(team)}
  end

  defp data(%Team{} = team) do
    %{
      id: team.id,
      name: team.name,
      description: team.description
    }
  end

  defp data([]), do: %{error: "No team found"}
  defp data(nil), do: %{error: "No team found"}

  defp data(teams) when is_list(teams) do
    Enum.map(teams, &data/1)
  end
end
