defmodule TimeManagerWeb.ManageController do
  use TimeManagerWeb, :controller
  alias TimeManager.Accounts
  alias TimeManager.Accounts.Manage
  action_fallback TimeManagerWeb.FallbackController

  def index(conn, params) do
    try do
      tasks = Manage.list_tasks!(params)
      if tasks == [] or tasks == nil do
        conn
        |> put_status(:not_found)
        |> json(%{error: "No tasks found"})
      else
        render(conn, :show, tasks: tasks)
      end
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Project not found"})
    end
  end

  def create(conn, %{"manage" => manage_params}) do
    with {:ok, %Manage{} = manage} <- Accounts.create_manage(manage_params) do
      conn
      |> put_status(:created)
      |> render("show.json", manage: manage)
    end
  end

  def show(conn, %{"id" => id}) do
    try do
      manage = Accounts.get_manage!(id)
      render(conn, "show.json", manage: manage)
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Manage not found"})
    end
  end

  def update(conn, %{"id" => id, "manage" => manage_params}) do
    with {:ok, %Manage{} = manage} <- Accounts.update_manage(id, manage_params) do
      conn
      |> put_status(:ok)
      |> render("show.json", manage: manage)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %Manage{}} <- Accounts.delete_manage(id) do
      conn
      |> put_status(:no_content)
      |> send_resp("", 204)
    end
  end
end
