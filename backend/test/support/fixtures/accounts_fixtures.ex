defmodule TimeManager.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TimeManager.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        username: "some username"
      })
      |> TimeManager.Accounts.create_user()

    user
  end

  @doc """
  Generate a teams.
  """
  def teams_fixture(attrs \\ %{}) do
    {:ok, teams} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> TimeManager.Accounts.create_teams()

    teams
  end

  @doc """
  Generate a manage.
  """
  def manage_fixture(attrs \\ %{}) do
    {:ok, manage} =
      attrs
      |> Enum.into(%{

      })
      |> TimeManager.Accounts.create_manage()

    manage
  end
end
