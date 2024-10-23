defmodule TimeManagerWeb.ManageController do
  use TimeManagerWeb, :controller

  alias TimeManager.Accounts
  alias TimeManager.Accounts.Manage

  action_fallback TimeManagerWeb.FallbackController

  def index(conn, params) do
    manage = Accounts.get_manage!(params)
    render(conn, :index, manage: manage)
  end

  def create(conn, %{"userId" => user_id, "teamId" => team_id}) do
      manage_params = %{"user_id" => user_id, "team_id" => team_id}

      with {:ok, %Manage{} = manage} <- Accounts.create_manage(manage_params) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/manage/#{manage}")
        |> render(:show, manage: manage)
      end


  end

  def show(conn, %{"id" => id}) do
    manage = Accounts.get_manage!(%{"id" => id})
    render(conn, :show, manage: manage)
  end

  def update(conn, %{"id" => id, "userId" => user_id, "teamId" => team_id}) do
    manage = Accounts.get_manage!(id)
    manage_params = %{"user_id" => user_id, "team_id" => team_id}
    with {:ok, %Manage{} = manage} <- Accounts.update_manage(manage, manage_params) do
      render(conn, :show, manage: manage)
    end
  end

  def delete(conn, %{"id" => id}) do
    manage = Accounts.get_manage!(id)

    with {:ok, %Manage{}} <- Accounts.delete_manage(manage) do
      send_resp(conn, :no_content, "")
    end
  end
end
