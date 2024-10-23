defmodule TimeManagerWeb.TeamsControllerTest do
  use TimeManagerWeb.ConnCase

  import TimeManager.AccountsFixtures

  alias TimeManager.Accounts.Teams

  @create_attrs %{
    name: "some name",
    description: "some description"
  }
  @update_attrs %{
    name: "some updated name",
    description: "some updated description"
  }
  @invalid_attrs %{name: nil, description: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all teams", %{conn: conn} do
      conn = get(conn, ~p"/api/teams")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create teams" do
    test "renders teams when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/teams", teams: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/teams/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/teams", teams: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update teams" do
    setup [:create_teams]

    test "renders teams when data is valid", %{conn: conn, teams: %Teams{id: id} = teams} do
      conn = put(conn, ~p"/api/teams/#{teams}", teams: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/teams/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, teams: teams} do
      conn = put(conn, ~p"/api/teams/#{teams}", teams: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete teams" do
    setup [:create_teams]

    test "deletes chosen teams", %{conn: conn, teams: teams} do
      conn = delete(conn, ~p"/api/teams/#{teams}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/teams/#{teams}")
      end
    end
  end

  defp create_teams(_) do
    teams = teams_fixture()
    %{teams: teams}
  end
end
