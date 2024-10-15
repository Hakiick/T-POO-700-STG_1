defmodule TimeManagerWeb.RhController do
  use TimeManagerWeb, :controller

  alias TimeManager.Accounts
  alias TimeManager.Accounts.Rh

  action_fallback TimeManagerWeb.FallbackController

  def index(conn, _params) do
    rhs = Accounts.list_rhs()
    render(conn, "index.json", rhs: rhs)
  end

  def show(conn, %{"id" => id}) do
    rh = Accounts.get_rh!(id)
    render(conn, "show.json", rh: rh)
  rescue
    Ecto.NoResultsError ->
      conn
      |> put_status(:not_found)
      |> json(%{error: "RH not found"})
  end

  def create(conn, %{"rh" => rh_params}) do
    with {:ok, %Rh{} = rh} <- Accounts.create_rh(rh_params) do
      conn
      |> put_status(:created)
      |> render("show.json", rh: rh)
    end
  end

  # Ajoutez les actions update et delete selon vos besoins
end
