defmodule TimeManagerWeb.UserRegistrationController do
  use TimeManagerWeb, :controller

  alias TimeManager.Accounts
  alias TimeManagerWeb.UserAuth

  def create(conn, %{"user" => user_params}) do
    # add the role to the user_params
    user_params = Map.put(user_params, "role", "user")
    # IO.inspect(user_params)

    case Accounts.register_user(user_params) do
      {:ok, user} ->
        # IO.inspect(user)
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/api/users/confirm/#{&1}")
          )

        conn
        |> put_status(:created)
        # |> json(%{ok: "user created"})
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        # conn
        # |> put_status(:bad_request)

        render(conn, :show, changeset: changeset)
        # |> put_status(:bad_request)
        # |> json(%{error: changeset.errors.full_messages})
    end
  end

  def confirm(conn, %{"token" => token}) do
    case Accounts.confirm_user(token) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "token not found"})

      _ ->
        conn
        |> put_status(:ok)
        |> json(%{ok: "user confirmed"})
    end
  end
end
