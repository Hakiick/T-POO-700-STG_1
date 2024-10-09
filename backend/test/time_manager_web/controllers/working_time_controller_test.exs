defmodule TimeManagerWeb.WorkingTimeControllerTest do
  use TimeManagerWeb.ConnCase

  import TimeManager.TimesheetFixtures
  import TimeManager.AccountsFixtures

  alias TimeManager.Accounts
  alias TimeManager.Accounts.User
  alias TimeManager.Repo
  alias TimeManager.Timesheet.WorkingTime

  @create_attrs %{
    user_id: 1,
    start: ~N[2024-10-07 12:18:09],
    end: ~N[2024-10-07 12:18:17]
  }
  @update_attrs %{
    start: ~N[2024-10-08 12:18:00],
    end: ~N[2024-10-08 12:18:00]
  }
  @invalid_attrs %{start: nil, end: nil}

  # Define your valid attributes for creating a user
  @valid_user_attrs %{
    username: "john_doe",
    email: "john@example.com"
  }

  setup %{conn: conn} do
    user =
      %User{}
      |> User.changeset(@valid_user_attrs)
      |> Repo.insert!()

    {:ok, conn: put_req_header(conn, "accept", "application/json"), user_id: user.id}
  end

  describe "index" do
    test "lists all workingtime", %{conn: conn, user_id: user_id} do
      conn = get(conn, ~p"/api/workingtime/1")

      assert json_response(conn, 200)["data"] == [
               %{
                 "id" => 1,
                 "end" => "2024-10-07T17:00:00Z",
                 "start" => "2024-10-07T09:00:00Z",
                 "user_id" => 1
               }
             ]
    end

    test "get a 404", %{conn: conn} do
      conn = get(conn, ~p"/api/workingtime/999")
      assert json_response(conn, 404) == %{"error" => "User not found"}
    end
  end

  describe "show" do
    test "get a workingtime", %{conn: conn, user_id: user_id} do
      conn = get(conn, ~p"/api/workingtime/1/1")

      assert json_response(conn, 200)["data"] == %{
               "id" => 1,
               "end" => "2024-10-07T17:00:00Z",
               "start" => "2024-10-07T09:00:00Z",
               "user_id" => 1
             }
    end

    test "get a 404", %{conn: conn} do
      conn = get(conn, ~p"/api/workingtime/999/666")
      assert json_response(conn, 404) == %{"error" => "Working time or user not found"}
    end
  end

  describe "create working_time" do
    setup [:create_working_time]

    test "renders working_time when data is valid", %{
      conn: conn,
      working_time: %WorkingTime{id: id} = working_time,
      user_id: user_id
    } do
      conn = post(conn, ~p"/api/workingtime/#{user_id}", working_time: @create_attrs)
      assert json_response(conn, 201)

      conn = get(conn, ~p"/api/workingtime/#{user_id}")

      assert [
               %{
                 "id" => id,
                 "end" => "2024-10-07T12:18:17Z",
                 "start" => "2024-10-07T12:18:09Z"
               }
             ] = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/workingtime/234", working_time: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update working_time" do
    setup [:create_working_time]

    test "renders working_time when data is valid", %{
      conn: conn,
      working_time: %WorkingTime{id: id} = working_time,
      user_id: user_id
    } do
      conn = put(conn, ~p"/api/workingtime/#{working_time.id}", working_time: @update_attrs)

      assert %{"user_id" => user_id, "id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/workingtime/#{user_id}/#{id}")

      assert %{
               "id" => ^id,
               "end" => "2024-10-08T12:18:00Z",
               "start" => "2024-10-08T12:18:00Z"
             } =
               json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, working_time: working_time} do
      conn = put(conn, ~p"/api/workingtime/#{working_time}", working_time: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete working_time" do
    setup [:create_working_time]

    test "deletes chosen working_time", %{conn: conn, working_time: working_time} do
      conn = delete(conn, ~p"/api/workingtime/#{working_time}")
      assert response(conn, 204)

      conn = get(conn, ~p"/api/workingtime/#{working_time}")
      assert response(conn, 404)
    end
  end

  defp create_working_time(_) do
    user = user_fixture()
    working_time = working_time_fixture(%{user_id: user.id})
    %{working_time: working_time}
  end
end
