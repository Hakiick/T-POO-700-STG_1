defmodule TimeManagerWeb.ManageJSON do
  alias TimeManager.Accounts.Manage

  @doc """
  Renders a list of manage entries.
  """
  def index(%{manages: manages}) do
    %{data: for(manage <- manages, do: data(manage))}
  end

  @doc """
  Renders a single manage entry.
  """
  def show(%{manage: manage}) do
    %{data: data(manage)}
  end

  defp data(%Manage{} = manage) do
    %{
      id: manage.id,
      team_id: manage.team_id,
      user_id: manage.user_id
    }
  end

  defp data([]), do: %{error: "No manage entry found"}
  defp data(nil), do: %{error: "No manage entry found"}

  defp data(manages) when is_list(manages) do
    Enum.map(manages, &data/1)
  end
end
