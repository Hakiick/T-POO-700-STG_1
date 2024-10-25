defmodule TimeManagerWeb.UserController do
  use TimeManagerWeb, :controller

  alias TimeManager.Accounts
  alias TimeManager.Accounts.User

  action_fallback TimeManagerWeb.FallbackController

  def get_from_jwt(conn, _params) do
    try do
      user = Guardian.Plug.current_resource(conn)

      conn
      |> put_resp_header("cache-control", "private, max-age=3600")
      |> render(:show, user: user)
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
    end
  end

  def show_from_mail_and_username(conn, params) do
    try do
      user = Accounts.get_user!(params)

      render(conn, "show.json", user: user)
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
    end
  end

  def index(conn, _param) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, user_params) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user.id}")
      |> render(:show, user: user)
    end
  end

  def show(conn, %{"userID" => id}) do
    try do
      user = Accounts.get_user!(%{"id" => id})
      render(conn, :show, user: user)
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
    end
  end

  def update(conn, %{"userID" => id, "user" => user_params}) do
    user = Accounts.get_user!(%{"id" => id})

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"userID" => id}) do
    user = Accounts.get_user!(%{"id" => id})

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
