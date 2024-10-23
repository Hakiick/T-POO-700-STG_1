defmodule TimeManagerWeb.ManageJSON do
  alias TimeManager.Accounts.Manage

  @doc """
  Renders a list of manage.
  """
  def index(%{manage: manage}) do
    %{data: for(manage <- manage, do: data(manage))}
  end

  @doc """
  Renders a single manage.
  """
  def show(%{manage: manage}) do
    %{data: data(manage)}
  end

  defp data(%Manage{} = manage) do
    %{
      id: manage.id,
      user: manage.user_id,
      team: manage.team_id
    }
  end
end
