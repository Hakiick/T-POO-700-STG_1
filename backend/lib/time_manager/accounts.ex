defmodule TimeManager.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias TimeManager.Repo

  alias TimeManager.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(params) do
    get_user_by(params)
  end

  defp get_user_by(%{"email" => email, "username" => username}) do
    Repo.one(from u in User, where: u.email == ^email and u.username == ^username)
  end

  defp get_user_by(%{"email" => email}) do
    Repo.one(from u in User, where: u.email == ^email)
  end

  defp get_user_by(%{"username" => username}) do
    Repo.one(from u in User, where: u.username == ^username)
  end

  defp get_user_by(%{"id" => id}) do
    Repo.get!(User, id)
  end

  defp get_user_by(_params) do
    Repo.all(User)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias TimeManager.Accounts.Teams

  @doc """
  Returns the list of teams.

  ## Examples

      iex> list_teams()
      [%Teams{}, ...]

  """
  def list_teams do
    Repo.all(Teams)
  end

  @doc """
  Gets a single teams.

  Raises `Ecto.NoResultsError` if the Teams does not exist.

  ## Examples

      iex> get_teams!(123)
      %Teams{}

      iex> get_teams!(456)
      ** (Ecto.NoResultsError)

  """
  def get_teams!(id), do: Repo.get!(Teams, id)

  @doc """
  Creates a teams.

  ## Examples

      iex> create_teams(%{field: value})
      {:ok, %Teams{}}

      iex> create_teams(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_teams(attrs \\ %{}) do
    %Teams{}
    |> Teams.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a teams.

  ## Examples

      iex> update_teams(teams, %{field: new_value})
      {:ok, %Teams{}}

      iex> update_teams(teams, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_teams(%Teams{} = teams, attrs) do
    teams
    |> Teams.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a teams.

  ## Examples

      iex> delete_teams(teams)
      {:ok, %Teams{}}

      iex> delete_teams(teams)
      {:error, %Ecto.Changeset{}}

  """
  def delete_teams(%Teams{} = teams) do
    Repo.delete(teams)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking teams changes.

  ## Examples

      iex> change_teams(teams)
      %Ecto.Changeset{data: %Teams{}}

  """
  def change_teams(%Teams{} = teams, attrs \\ %{}) do
    Teams.changeset(teams, attrs)
  end

  alias TimeManager.Accounts.Manage

  @doc """
  Returns the list of manage.

  ## Examples

      iex> list_manage()
      [%Manage{}, ...]

  """
  def list_manage do
    Repo.all(Manage)
  end

  @doc """
  Gets a single manage.

  Raises `Ecto.NoResultsError` if the Manage does not exist.

  ## Examples

      iex> get_manage!(123)
      %Manage{}

      iex> get_manage!(456)
      ** (Ecto.NoResultsError)

  """
  def get_manage!(params) do
    get_manage_by(params)
  end

  defp get_manage_by(%{ "user_id" => user_id, "team_id" => team_id}), do: Repo.all(from m in Manage, where: m.team_id == ^team_id and m.user_id == ^user_id)

  defp get_manage_by(%{"team_id" => team_id}), do: Repo.all(from m in Manage, where: m.team_id == ^team_id)

  defp get_manage_by(%{"user_id" => user_id}), do: Repo.all(from m in Manage, where: m.user_id == ^user_id)

  defp get_manage_by(%{"id" => id}), do: Repo.get!(Manage, id)

  defp get_manage_by(_params), do: Repo.all(Manage)

  @doc """
  Creates a manage.

  ## Examples

      iex> create_manage(%{field: value})
      {:ok, %Manage{}}

      iex> create_manage(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_manage(attrs \\ %{}) do
    %Manage{}
    |> Manage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a manage.

  ## Examples

      iex> update_manage(manage, %{field: new_value})
      {:ok, %Manage{}}

      iex> update_manage(manage, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_manage(%Manage{} = manage, attrs) do
    manage
    |> Manage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a manage.

  ## Examples

      iex> delete_manage(manage)
      {:ok, %Manage{}}

      iex> delete_manage(manage)
      {:error, %Ecto.Changeset{}}

  """
  def delete_manage(%Manage{} = manage) do
    Repo.delete(manage)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking manage changes.

  ## Examples

      iex> change_manage(manage)
      %Ecto.Changeset{data: %Manage{}}

  """
  def change_manage(%Manage{} = manage, attrs \\ %{}) do
    Manage.changeset(manage, attrs)
  end
end
