defmodule TimeManagerWeb.ManageJSON do
  alias TimeManager.Accounts.Manage
  alias TimeManager.Accounts.User
  alias TimeManager.Accounts.Teams

  @doc """
  Renders a list of manage.
  """
  def index(%{manage: manage}) do
    %{data: for(manage <- manage, do: data(manage))}
  end

  def index(%{teams: teams}) do
    %{data: for(team <- teams, do: data(team))}
  end

  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single manage.
  """
  def show(%{manage: manage}) do
    %{data: data(manage)}
  end

  defp data(%Teams{} = team) do
    %{
      id: team.id,
      name: team.name,
      description: team.description
    }
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      username: user.username,
      email: user.email,
      role: user.role
    }
  end

  defp data(%Manage{} = manage) do
    %{
      id: manage.id,
      user: manage.user_id,
      team: manage.team_id
    }
  end
end
