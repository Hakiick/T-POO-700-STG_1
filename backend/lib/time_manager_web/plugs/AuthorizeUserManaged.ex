defmodule TimeManagerWeb.Plugs.AuthorizeUserManaged do
  import Plug.Conn
  import Phoenix.Controller

  alias Guardian.Plug
  alias TimeManager.Accounts

  def init(default), do: default

  def call(conn, _opts) do
    # Retrieve the current user using Guardian's `current_resource`
    authenticated_user = Plug.current_resource(conn)
    requested_user_id = conn.params["userID"]

    if Integer.to_string(authenticated_user.id) == requested_user_id ||
         authenticated_user.role == "general_manager" do
      conn
    else
      is_managed = Accounts.is_managed_by?(requested_user_id, authenticated_user.id)

      if is_managed do
        conn
      else
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You are not allowed to access this resource"})
      end
    end
  end
end
