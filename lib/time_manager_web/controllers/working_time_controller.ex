defmodule TimeManagerWeb.WorkingTimeController do
  use TimeManagerWeb, :controller

  alias TimeManager.Timesheet
  alias TimeManager.Timesheet.WorkingTime
  alias TimeManager.Accounts

  action_fallback(TimeManagerWeb.FallbackController)

  def index(conn, %{"userID" => id}) do
    try do
      user = Accounts.get_user!(id)

      workingtimes = Timesheet.list_workingtime_from_a_user(user.id)

      if workingtimes == [] do
        conn
        |> put_status(:not_found)
        |> json(%{error: "No workingtimes found"})
      else
        render(conn, :index, workingtime: workingtimes)
      end
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
    end
  end

  def create(conn, %{"working_time" => working_time_params, "userID" => user_id}) do
    # Merge the user_id into clock_params
    working_time_params = Map.put(working_time_params, "user_id", user_id)

    with {:ok, %WorkingTime{} = working_time} <-
           Timesheet.create_working_time(working_time_params) do
      conn
      |> put_status(:created)
      |> json(%{data: "created"})

      # |> put_resp_header("location", ~p"/api/workingtime/#{working_time}")
      # |> render(:show, working_time: working_time)
    end
  end

  def show(conn, %{"userID" => user_id, "id" => id}) do
    try do
      working_time = Timesheet.get_working_time_by_user!(user_id, id)
      render(conn, :show, working_time: working_time)
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Working time not found"})
    end
  end

  def update(conn, %{"userID" => id, "working_time" => working_time_params}) do
    working_time = Timesheet.get_working_time!(id)

    with {:ok, %WorkingTime{} = working_time} <-
           Timesheet.update_working_time(working_time, working_time_params) do
      render(conn, :show, working_time: working_time)
    end
  end

  def delete(conn, %{"userID" => id}) do
    working_time = Timesheet.get_working_time!(id)

    with {:ok, %WorkingTime{}} <- Timesheet.delete_working_time(working_time) do
      send_resp(conn, :no_content, "")
    end
  end
end
