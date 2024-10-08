defmodule TimeManagerWeb.ClockControllerTest do
  use TimeManagerWeb.ConnCase, async: false

  import TimeManager.TimesheetFixtures

  alias TimeManager.Accounts
  alias TimeManager.Accounts.User
  alias TimeManager.Repo
  alias TimeManager.Timesheet.Clock

  @create_attrs %{
    status: true,
    time: ~N[2024-10-07 12:18:00]
  }
  @update_attrs %{
    status: false,
    time: ~N[2024-10-08 12:18:00]
  }
  @invalid_attrs %{status: nil, time: nil, user_id: nil}

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

  describe "show" do
    test "lists a clock from a user", %{conn: conn, user_id: user_id} do
      conn = get(conn, ~p"/api/clocks/#{user_id}")
      assert json_response(conn, 200)["data"] == %{"error" => "No clocks found"}
    end
  end

  describe "create clock" do
    test "renders clock when data is valid", %{conn: conn, user_id: user_id} do
      conn = post(conn, ~p"/api/clocks/#{user_id}", clock: @create_attrs)
      assert json_response(conn, 201)

      conn = get(conn, ~p"/api/clocks/#{user_id}")

      assert [%{
               "id" => 2,
               "status" => true,
               "time" => "2024-10-07T12:18:00"
             }] = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/clocks/234", clock: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  # describe "show" do
  #   test "lists a clock from a user", %{conn: conn, user_id: user_id} do
  #     conn = get(conn, ~p"/api/clocks/#{user_id}")
  #     assert json_response(conn, 200)["data"] == %{"error" => "No clocks found"}
  #   end
  # end

  defp create_clock(_) do
    clock = clock_fixture()
    %{clock: clock}
  end
end
