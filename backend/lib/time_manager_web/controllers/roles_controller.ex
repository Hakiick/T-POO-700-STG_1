defmodule TimeManagerWeb.RolesController do
  use TimeManagerWeb, :controller
  alias TimeManager.Accounts
  alias TimeManager.Accounts.Role
  action_fallback TimeManagerWeb.FallbackController

  def index(conn, params) do
    try do
      roles = Roles.list_roles!(params)
      if roles == [] or roles == nil do
        conn
        |> put_status(:not_found)
        |> json(%{error: "No roles found"})
      else
        render(conn, :show, roles: roles)
      end
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Role not found"})
    end
  end

  def show(conn, %{"id" => id}) do
    try do
      role = Accounts.get_role!(id)
      render(conn, "show.json", role: role)
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Role not found"})
    end
  end

  def create(conn, %{"role" => role_params}) do
    with {:ok, %Role{} = role} <- Accounts.create_role(role_params) do
      conn
      |> put_status(:created)
      |> render("show.json", role: role)
    end
  end

  def update(conn, %{"id" => id, "role" => role_params}) do
    with {:ok, %Role{} = role} <- Accounts.update_role(id, role_params) do
      conn
      |> put_status(:ok)
      |> render("show.json", role: role)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %Role{} = role} <- Accounts.delete_role(id) do
      conn
      |> put_status(:no_content)
      |> json(%{})
    end
  end
end
