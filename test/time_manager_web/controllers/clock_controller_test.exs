defmodule TimeManagerWeb.ClockControllerTest do
  use TimeManagerWeb.ConnCase

  import TimeManager.TimesheetFixtures

  alias TimeManager.Timesheet.Clock

  @create_attrs %{
    status: true,
    time: ~N[2024-10-07 12:18:00]
  }
  @update_attrs %{
    status: false,
    time: ~N[2024-10-08 12:18:00]
  }
  @invalid_attrs %{status: nil, time: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all clocks from a user", %{conn: conn} do
      conn = get(conn, ~p"/api/clocks/")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create clock" do
    test "renders clock when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/clocks", clock: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/clocks/#{id}")

      assert %{
               "id" => ^id,
               "status" => true,
               "time" => "2024-10-07T12:18:00"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/clocks", clock: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_clock(_) do
    clock = clock_fixture()
    %{clock: clock}
  end
end
