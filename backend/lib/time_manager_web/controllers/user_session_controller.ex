defmodule TimeManagerWeb.UserSessionController do
  use TimeManagerWeb, :controller

  alias TimeManager.Accounts
  alias TimeManagerWeb.UserAuth

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> UserAuth.log_in_user(user)
    else
      conn
      |> put_status(:not_found)
      |> json(%{error: "Email or password is incorrect."})
    end
  end

  def refresh(conn, _params) do
    UserAuth.refresh_token(conn)
  end
end
