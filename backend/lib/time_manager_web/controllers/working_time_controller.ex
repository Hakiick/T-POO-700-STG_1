defmodule TimeManagerWeb.WorkingTimeController do
  use TimeManagerWeb, :controller

  alias TimeManager.Timesheet
  alias TimeManager.Timesheet.WorkingTime

  action_fallback(TimeManagerWeb.FallbackController)

  def index(conn, params) do
    try do
      # user = Accounts.get_user!(%{"id" => params["userID"]})
      working_times = Timesheet.list_workingtime_from_a_user!(params)

      if working_times == [] or working_times == nil do
        conn
        |> put_status(:not_found)
        |> json(%{error: "No workingtimes found"})
      else
        render(conn, :show, working_time: working_times)
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

    with {:ok, %WorkingTime{}} <-
           Timesheet.create_working_time(working_time_params) do
      conn
      |> put_status(:created)
      |> json(%{data: "created"})

      #|> put_resp_header("location", ~p"/api/workingtime/#{working_time}")
      #|> render(:show, working_time: working_time)
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
        |> json(%{error: "Working time or user not found"})
    end
  end

  def update(conn, %{"id" => id, "working_time" => working_time_params}) do
    working_time = Timesheet.get_working_time!(id)

    with {:ok, %WorkingTime{} = working_time} <-
           Timesheet.update_working_time_from_id(working_time, working_time_params) do
      render(conn, :show, working_time: working_time)
    end
  end

  def delete(conn, %{"id" => id}) do
    working_time = Timesheet.get_working_time!(id)

    with {:ok, %WorkingTime{}} <- Timesheet.delete_working_time(working_time) do
      send_resp(conn, :no_content, "")
    end
  end
end
