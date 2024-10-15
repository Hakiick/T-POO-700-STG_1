defmodule TimeManagerWeb.UserJSON do
  alias TimeManager.Accounts.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      username: user.username,
      email: user.email,
      is_active: user.is_active,
      team_id: user.team_id,
      role_id: user.role_id
    }
  end

  # Handle empty list or nil case
  defp data([]), do: %{error: "No user found"}
  defp data(nil), do: %{error: "No user found"}

  # Handle a list of User structs
  defp data(users) when is_list(users) do
    # Map each user to the data function
    Enum.map(users, &data/1)
  end
end
