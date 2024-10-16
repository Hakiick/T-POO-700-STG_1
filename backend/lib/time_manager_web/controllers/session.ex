defmodule TimeManagerWeb.SessionController do
  use TimeManagerWeb, :controller
  alias TimeManager.Accounts.User
  import Argon2

  def create(conn, %{"user" => user_params}) do
    case authenticate_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Bienvenue #{user.username}!")
        |> redirect(to: "/")
      {:error, reason} ->
        conn
        |> put_flash(:error, "Échec de la connexion: #{reason}")
        |> redirect(to: "/login")
    end
  end

  def authenticate_user(%{"username" => username, "password" => password}) do
    user = Accounts.get_user_by_username(username)

    case user do
      nil ->
        {:error, "Utilisateur non trouvé"}
      %User{} = user ->
        if check_password(user, password) do
          {:ok, user}
        else
          {:error, "Mot de passe incorrect"}
        end
    end
  end

  def check_password(user, password) do
    Argon2.verify_pass(password, user.password_hash)
  end
end
