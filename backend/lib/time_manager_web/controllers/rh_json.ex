defmodule TimeManagerWeb.RhJSON do
  alias TimeManager.Accounts.Rh

  @doc """
  Renders a list of RH entries.
  """
  def index(%{rhs: rhs}) do
    %{data: for(rh <- rhs, do: data(rh))}
  end

  @doc """
  Renders a single RH entry.
  """
  def show(%{rh: rh}) do
    %{data: data(rh)}
  end

  defp data(%Rh{} = rh) do
    %{
      id: rh.id,
      employee_id: rh.employee_id,
      department: rh.department
    }
  end

  defp data([]), do: %{error: "No RH entry found"}
  defp data(nil), do: %{error: "No RH entry found"}

  defp data(rhs) when is_list(rhs) do
    Enum.map(rhs, &data/1)
  end
end
