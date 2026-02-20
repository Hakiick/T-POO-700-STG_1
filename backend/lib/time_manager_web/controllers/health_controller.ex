defmodule TimeManagerWeb.HealthController do
  use TimeManagerWeb, :controller

  def index(conn, _params) do
    case check_database() do
      :ok ->
        conn
        |> put_status(200)
        |> json(%{status: "healthy", database: "connected"})

      {:error, reason} ->
        conn
        |> put_status(503)
        |> json(%{status: "unhealthy", database: "disconnected", error: inspect(reason)})
    end
  end

  defp check_database do
    try do
      Ecto.Adapters.SQL.query!(TimeManager.Repo, "SELECT 1 as health")
      :ok
    rescue
      e -> {:error, e}
    end
  end
end
