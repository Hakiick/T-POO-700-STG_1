defmodule TimeManagerWeb.UserAuth do
  use TimeManagerWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias TimeManager.Guardian

  @doc """
  Logs the user in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """
  def log_in_user(conn, user) do
    {:ok, refresh_token, _full_claims} =
      Guardian.encode_and_sign(user, %{}, token_type: "refresh")

    {:ok, acces_token, _full_claims} =
      Guardian.encode_and_sign(user, %{}, token_type: "acces_token")

    conn
    # |> put_resp_cookie("auth_token", jwt, http_only: true)
    |> json(%{
      refresh_token: refresh_token,
      acces_token: acces_token,
      message: "User logged in successfully."
    })
  end

  def refresh_token(conn) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid refresh token"})

      user ->
        {:ok, new_token, _claims} =
          Guardian.encode_and_sign(user, %{}, ttl: {1, :hours})

        conn
        |> json(%{refresh_token: new_token, message: "token refreshed successfully."})
    end
  end
end
