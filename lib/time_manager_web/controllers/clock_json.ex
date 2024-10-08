defmodule TimeManagerWeb.ClockJSON do
  alias TimeManager.Timesheet.Clock

  @doc """
  Renders a list of clocks.
  """
  def index(%{clocks: clocks}) do
    %{data: for(clock <- clocks, do: data(clock))}
  end

  @doc """
  Renders a single clock.
  """
  def show(%{clock: clock}) do
    %{data: data(clock)}
  end

  # Handle a single Clock structs
  defp data(%Clock{} = clock) do
    %{
      id: clock.id,
      time: clock.time,
      status: clock.status
    }
  end

  # Handle empty list or nil case
  defp data([]), do: %{error: "No clocks found"}
  defp data(nil), do: %{error: "No clocks found"}

  # Handle a list of Clock structs
  defp data(clocks) when is_list(clocks) do
    # Map each clock to the data function
    Enum.map(clocks, &data/1)
  end
end
