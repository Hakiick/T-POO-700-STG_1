defmodule TimeManagerWeb.ClockController do
  use TimeManagerWeb, :controller

  alias TimeManager.Timesheet
  alias TimeManager.Timesheet.Clock
  alias TimeManager.Accounts

  action_fallback(TimeManagerWeb.FallbackController)

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

  def show(conn, %{"userID" => id}) do
    try do
      user = Accounts.get_user!(id)

      clocks = Timesheet.get_clock!(user.id)
      # IO.inspect(clocks)

      render(conn, :show, clock: clocks)
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
    end
  end
end
