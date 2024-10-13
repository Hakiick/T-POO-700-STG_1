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

  def create(conn, %{"clock" => clock_params, "userID" => user_id}) do
    # Merge the user_id into clock_params
    clock_params = Map.put(clock_params, "user_id", user_id)

    # Insert the clock into the database
    with {:ok, %Clock{} = clock} <- Timesheet.create_clock(clock_params) do
      if clock.status == false do
        last_clock_in = Timesheet.get_last_clock_in(user_id)

        Timesheet.create_working_time(%{
          start: last_clock_in.time,
          end: clock.time,
          user_id: user_id
        })
      end

      conn
      |> put_status(:created)
      |> json(%{data: "created"})

      # |> put_resp_header("location", ~p"/api/clocks/#{clock}")
      # |> render(:show, clock: clock)
    end
  end

  def show(conn, %{"userID" => id}) do
    try do
      user = Accounts.get_user!(%{"id" => id})

      clocks = Timesheet.get_clock!(user.id)

      if clocks == [] do
        conn
        |> put_status(:not_found)
        |> json(%{error: "No clocks found"})
      else
        render(conn, :show, clock: clocks)
      end
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
    end
  end
end
