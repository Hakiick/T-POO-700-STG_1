defmodule TimeManager.AccountsTest do
  use TimeManager.DataCase

  alias TimeManager.Accounts

  describe "users" do
    alias TimeManager.Accounts.User

    import TimeManager.AccountsFixtures

    @invalid_attrs %{username: nil, email: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{username: "some username", email: "some email"}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.username == "some username"
      assert user.email == "some email"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{username: "some updated username", email: "some updated email"}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.username == "some updated username"
      assert user.email == "some updated email"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "teams" do
    alias TimeManager.Accounts.Teams

    import TimeManager.AccountsFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_teams/0 returns all teams" do
      teams = teams_fixture()
      assert Accounts.list_teams() == [teams]
    end

    test "get_teams!/1 returns the teams with given id" do
      teams = teams_fixture()
      assert Accounts.get_teams!(teams.id) == teams
    end

    test "create_teams/1 with valid data creates a teams" do
      valid_attrs = %{name: "some name", description: "some description"}

      assert {:ok, %Teams{} = teams} = Accounts.create_teams(valid_attrs)
      assert teams.name == "some name"
      assert teams.description == "some description"
    end

    test "create_teams/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_teams(@invalid_attrs)
    end

    test "update_teams/2 with valid data updates the teams" do
      teams = teams_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %Teams{} = teams} = Accounts.update_teams(teams, update_attrs)
      assert teams.name == "some updated name"
      assert teams.description == "some updated description"
    end

    test "update_teams/2 with invalid data returns error changeset" do
      teams = teams_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_teams(teams, @invalid_attrs)
      assert teams == Accounts.get_teams!(teams.id)
    end

    test "delete_teams/1 deletes the teams" do
      teams = teams_fixture()
      assert {:ok, %Teams{}} = Accounts.delete_teams(teams)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_teams!(teams.id) end
    end

    test "change_teams/1 returns a teams changeset" do
      teams = teams_fixture()
      assert %Ecto.Changeset{} = Accounts.change_teams(teams)
    end
  end

  describe "manage" do
    alias TimeManager.Accounts.Manage

    import TimeManager.AccountsFixtures

    @invalid_attrs %{}

    test "list_manage/0 returns all manage" do
      manage = manage_fixture()
      assert Accounts.list_manage() == [manage]
    end

    test "get_manage!/1 returns the manage with given id" do
      manage = manage_fixture()
      assert Accounts.get_manage!(manage.id) == manage
    end

    test "create_manage/1 with valid data creates a manage" do
      valid_attrs = %{}

      assert {:ok, %Manage{} = manage} = Accounts.create_manage(valid_attrs)
    end

    test "create_manage/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_manage(@invalid_attrs)
    end

    test "update_manage/2 with valid data updates the manage" do
      manage = manage_fixture()
      update_attrs = %{}

      assert {:ok, %Manage{} = manage} = Accounts.update_manage(manage, update_attrs)
    end

    test "update_manage/2 with invalid data returns error changeset" do
      manage = manage_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_manage(manage, @invalid_attrs)
      assert manage == Accounts.get_manage!(manage.id)
    end

    test "delete_manage/1 deletes the manage" do
      manage = manage_fixture()
      assert {:ok, %Manage{}} = Accounts.delete_manage(manage)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_manage!(manage.id) end
    end

    test "change_manage/1 returns a manage changeset" do
      manage = manage_fixture()
      assert %Ecto.Changeset{} = Accounts.change_manage(manage)
    end
  end
end
