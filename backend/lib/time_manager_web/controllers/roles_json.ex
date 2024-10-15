defmodule TimeManagerWeb.RolesJSON do
  alias TimeManager.Accounts.Role

  @doc """
  Renders a list of roles.
  """
  def index(%{roles: roles}) do
    %{data: for(role <- roles, do: data(role))}
  end

  @doc """
  Renders a single role.
  """
  def show(%{role: role}) do
    %{data: data(role)}
  end

  defp data(%Role{} = role) do
    %{
      id: role.id,
      name: role.name,
      description: role.description
    }
  end

  defp data([]), do: %{error: "No role found"}
  defp data(nil), do: %{error: "No role found"}

  defp data(roles) when is_list(roles) do
    Enum.map(roles, &data/1)
  end
end
