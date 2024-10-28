defmodule TimeManagerWeb.Plugs.RolePlug do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  # Assuming roles are stored here
  alias TimeManager.Accounts
  # Assuming Guardian is your JWT library
  alias TimeManager.Guardian

  def init(default), do: default

  def call(conn, opts) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Unauthorized"})
        |> halt()

      %Accounts.User{role: role} = _user ->
        if role in opts[:roles] do
          conn
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Forbidden"})
          |> halt()
        end
    end
  end
end
