defmodule TimeManagerWeb.RhController do
  use TimeManagerWeb, :controller
  alias TimeManager.Accounts
  alias TimeManager.Accounts.Rh
  action_fallback TimeManagerWeb.FallbackController

  def index(conn, params) do
    try do
      employees = RH.list_employees!(params)
      if employees == [] or employees == nil do
        conn
        |> put_status(:not_found)
        |> json(%{error: "No employees found"})
      else
        render(conn, :show, employees: employees)
      end
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Employee not found"})
    end
  end

  def show(conn, %{"id" => id}) do
    try do
      rh = Accounts.get_rh!(id)
      render(conn, "show.json", rh: rh)
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "RH not found"})
    end
  end

  def create(conn, %{"rh" => rh_params}) do
    with {:ok, %Rh{} = rh} <- Accounts.create_rh(rh_params) do
      conn
      |> put_status(:created)
      |> render("show.json", rh: rh)
    end
  end

  def update(conn, %{"id" => id, "rh" => rh_params}) do
    with {:ok, %Rh{} = rh} <- Accounts.update_rh(id, rh_params) do
      conn
      |> put_status(:ok)
      |> render("show.json", rh: rh)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %Rh{}} <- Accounts.delete_rh(id) do
      conn
      |> put_status(:no_content)
      |> send_resp("", 204)
    end
  end
end
