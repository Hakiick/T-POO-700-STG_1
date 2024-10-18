# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TimeManager.Repo.insert!(%TimeManager.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TimeManager.Repo
import TimeManager.Accounts
alias TimeManager.Accounts.User
alias TimeManager.Timesheet.Clock
alias TimeManager.Timesheet.WorkingTime

# Create a new user with the desired attributes
user_attrs = %{
  username: "Karl_le_pd",
  email: "Karl_le_pd@pd.com",
  password: "pd1234567890"
}

# Check if the user already exists to avoid duplication
case Repo.get_by(User, email: user_attrs.email) do
  nil ->
    %User{}
    |> User.registration_changeset(user_attrs)
    # Use insert! to raise an error if the insert fails
    |> Repo.insert!()

    IO.puts("User created successfully.")

  _existing_user ->
    IO.puts("User already exists.")
end

# Define clock attributes for the user
clock_attrs = %{
  time: ~N[2024-10-07 09:00:00],
  status: true,
  user_id: 1
}

# Check if the clock already exists for this user
case Repo.get_by(Clock,
       time: clock_attrs.time,
       status: clock_attrs.status
     ) do
  nil ->
    %Clock{}
    |> Clock.changeset(clock_attrs)
    |> Repo.insert!()

    IO.puts("Clock created successfully.")

  _existing_clock ->
    IO.puts("Clock already exists for this user.")
end

# Define working time attributes for the user
working_time_attrs = %{
  start: ~N[2024-10-07 09:00:00],
  end: ~N[2024-10-07 17:00:00],
  user_id: 1
}

# Check if working time already exists for this user
case Repo.get_by(WorkingTime,
       start: working_time_attrs.start,
       end: working_time_attrs.end
     ) do
  nil ->
    %WorkingTime{}
    |> WorkingTime.changeset(working_time_attrs)
    |> Repo.insert!()

    IO.puts("Working time created successfully.")

  _existing_working_time ->
    IO.puts("Working time already exists for this user.")
end
