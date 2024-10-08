defmodule TimeManagerWeb.ClockController do
  use TimeManagerWeb, :controller

  alias TimeManager.Timesheet
  alias TimeManager.Timesheet.Clock

  action_fallback TimeManagerWeb.FallbackController

  def index(conn, _params) do
    clocks = Timesheet.list_clocks()
    render(conn, :index, clocks: clocks)
  end

  def create(conn, %{"clock" => clock_params}) do
    with {:ok, %Clock{} = clock} <- Timesheet.create_clock(clock_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/clocks/#{clock}")
      |> render(:show, clock: clock)
    end
  end

  def show(conn, %{"id" => id}) do
    clock = Timesheet.get_clock!(id)
    render(conn, :show, clock: clock)
  end
end
