defmodule TimeManagerWeb.WorkingTimeJSON do
  alias TimeManager.Timesheet.WorkingTime

  @doc """
  Renders a list of workingtime.
  """
  def index(%{workingtime: workingtime}) do
    %{data: for(working_time <- workingtime, do: data(working_time))}
  end

  @doc """
  Renders a single working_time.
  """
  def show(%{working_time: working_time}) do
    %{data: data(working_time)}
  end

  defp data(%WorkingTime{} = working_time) do
    %{
      id: working_time.id,
      start: working_time.start,
      end: working_time.end,
      user_id: working_time.user_id
    }
  end

  # Handle a list of Clock structs
  defp data(working_times) when is_list(working_times) do
    # Map each clock to the data function
    Enum.map(working_times, &data/1)
  end
end
