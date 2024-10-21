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
alias TimeManager.Accounts.User
alias TimeManager.Timesheet.Clock
alias TimeManager.Timesheet.WorkingTime

# Create a new user with the desired attributes
user_attrs = %{
  username: "Karl_le_pd",
  email: "Karl_le_pd@pd.com"
}

# Check if the user already exists to avoid duplication
case Repo.get_by(User, email: user_attrs.email) do
  nil ->
    %User{}
    |> User.changeset(user_attrs)
    # Use insert! to raise an error if the insert fails
    |> Repo.insert!()

    IO.puts("User created successfully.")

  _existing_user ->
    IO.puts("User already exists.")
end

# Define clock attributes for the user
clock_attrs = [
  # Week 1 (26 août - 01 septembre)
  %{time: ~N[2024-08-26 07:00:00], status: true, user_id: 1},   # Monday - Pointage d'entrée
  %{time: ~N[2024-08-26 16:00:00], status: false, user_id: 1},  # Monday - Pointage de sortie
  %{time: ~N[2024-08-27 07:00:00], status: true, user_id: 1},   # Tuesday - Pointage d'entrée
  %{time: ~N[2024-08-27 16:00:00], status: false, user_id: 1},  # Tuesday - Pointage de sortie
  %{time: ~N[2024-08-28 07:00:00], status: true, user_id: 1},   # Wednesday - Pointage d'entrée
  %{time: ~N[2024-08-28 16:00:00], status: false, user_id: 1},  # Wednesday - Pointage de sortie
  %{time: ~N[2024-08-29 07:00:00], status: true, user_id: 1},   # Thursday - Pointage d'entrée
  %{time: ~N[2024-08-29 16:00:00], status: false, user_id: 1},  # Thursday - Pointage de sortie
  %{time: ~N[2024-08-30 07:00:00], status: true, user_id: 1},   # Friday - Pointage d'entrée
  %{time: ~N[2024-08-30 16:00:00], status: false, user_id: 1},  # Friday - Pointage de sortie
  %{time: ~N[2024-08-31 09:00:00], status: true, user_id: 1},   # Saturday - Pointage d'entrée
  %{time: ~N[2024-08-31 18:00:00], status: false, user_id: 1},  # Saturday - Pointage de sortie

  # Week 2 (02 septembre - 08 septembre)
  %{time: ~N[2024-09-02 08:00:00], status: true, user_id: 1},   # Monday - Pointage d'entrée
  %{time: ~N[2024-09-02 19:00:00], status: false, user_id: 1},  # Monday - Pointage de sortie
  %{time: ~N[2024-09-03 08:00:00], status: true, user_id: 1},   # Tuesday - Pointage d'entrée
  %{time: ~N[2024-09-03 19:00:00], status: false, user_id: 1},  # Tuesday - Pointage de sortie
  %{time: ~N[2024-09-04 08:00:00], status: true, user_id: 1},   # Wednesday - Pointage d'entrée
  %{time: ~N[2024-09-04 19:00:00], status: false, user_id: 1},  # Wednesday - Pointage de sortie
  %{time: ~N[2024-09-05 08:00:00], status: true, user_id: 1},   # Thursday - Pointage d'entrée
  %{time: ~N[2024-09-05 19:00:00], status: false, user_id: 1},  # Thursday - Pointage de sortie
  %{time: ~N[2024-09-06 08:00:00], status: true, user_id: 1},   # Friday - Pointage d'entrée
  %{time: ~N[2024-09-06 19:00:00], status: false, user_id: 1},  # Friday - Pointage de sortie
  %{time: ~N[2024-09-07 09:00:00], status: true, user_id: 1},   # Saturday - Pointage d'entrée
  %{time: ~N[2024-09-07 18:00:00], status: false, user_id: 1},  # Saturday - Pointage de sortie

  # Week 3 (09 septembre - 15 septembre)
  %{time: ~N[2024-09-09 07:00:00], status: true, user_id: 1},   # Monday - Pointage d'entrée
  %{time: ~N[2024-09-09 12:00:00], status: false, user_id: 1},  # Monday - Pointage de sortie
  %{time: ~N[2024-09-10 13:00:00], status: true, user_id: 1},   # Tuesday - Pointage d'entrée
  %{time: ~N[2024-09-10 18:00:00], status: false, user_id: 1},  # Tuesday - Pointage de sortie
  %{time: ~N[2024-09-11 07:00:00], status: true, user_id: 1},   # Wednesday - Pointage d'entrée
  %{time: ~N[2024-09-11 12:00:00], status: false, user_id: 1},  # Wednesday - Pointage de sortie
  %{time: ~N[2024-09-12 07:00:00], status: true, user_id: 1},   # Thursday - Pointage d'entrée
  %{time: ~N[2024-09-12 12:00:00], status: false, user_id: 1},  # Thursday - Pointage de sortie
  %{time: ~N[2024-09-13 07:00:00], status: true, user_id: 1},   # Friday - Pointage d'entrée
  %{time: ~N[2024-09-13 12:00:00], status: false, user_id: 1},  # Friday - Pointage de sortie
  %{time: ~N[2024-09-14 09:00:00], status: true, user_id: 1},   # Saturday - Pointage d'entrée
  %{time: ~N[2024-09-14 20:00:00], status: false, user_id: 1},  # Saturday - Pointage de sortie

  # Week 4 (16 septembre - 22 septembre)
  %{time: ~N[2024-09-16 09:00:00], status: true, user_id: 1},   # Monday - Pointage d'entrée
  %{time: ~N[2024-09-16 20:00:00], status: false, user_id: 1},  # Monday - Pointage de sortie
  %{time: ~N[2024-09-17 09:00:00], status: true, user_id: 1},   # Tuesday - Pointage d'entrée
  %{time: ~N[2024-09-17 20:00:00], status: false, user_id: 1},  # Tuesday - Pointage de sortie
  %{time: ~N[2024-09-18 09:00:00], status: true, user_id: 1},   # Wednesday - Pointage d'entrée
  %{time: ~N[2024-09-18 20:00:00], status: false, user_id: 1},  # Wednesday - Pointage de sortie
  %{time: ~N[2024-09-19 09:00:00], status: true, user_id: 1},   # Thursday - Pointage d'entrée
  %{time: ~N[2024-09-19 20:00:00], status: false, user_id: 1},  # Thursday - Pointage de sortie
  %{time: ~N[2024-09-20 09:00:00], status: true, user_id: 1},   # Friday - Pointage d'entrée
  %{time: ~N[2024-09-20 20:00:00], status: false, user_id: 1},  # Friday - Pointage de sortie
  %{time: ~N[2024-09-21 10:00:00], status: true, user_id: 1},   # Saturday - Pointage d'entrée
  %{time: ~N[2024-09-21 19:00:00], status: false, user_id: 1},  # Saturday - Pointage de sortie

  # Week 5 (23 septembre - 29 septembre)
  %{time: ~N[2024-09-23 07:00:00], status: true, user_id: 1},   # Monday - Pointage d'entrée
  %{time: ~N[2024-09-23 19:00:00], status: false, user_id: 1},  # Monday - Pointage de sortie
  %{time: ~N[2024-09-24 07:00:00], status: true, user_id: 1},   # Tuesday - Pointage d'entrée
  %{time: ~N[2024-09-24 19:00:00], status: false, user_id: 1},  # Tuesday - Pointage de sortie
  %{time: ~N[2024-09-25 07:00:00], status: true, user_id: 1},   # Wednesday - Pointage d'entrée
  %{time: ~N[2024-09-25 19:00:00], status: false, user_id: 1},  # Wednesday - Pointage de sortie
  %{time: ~N[2024-09-26 07:00:00], status: true, user_id: 1},   # Thursday - Pointage d'entrée
  %{time: ~N[2024-09-26 19:00:00], status: false, user_id: 1},  # Thursday - Pointage de sortie
  %{time: ~N[2024-09-27 07:00:00], status: true, user_id: 1},   # Friday - Pointage d'entrée
  %{time: ~N[2024-09-27 19:00:00], status: false, user_id: 1},  # Friday - Pointage de sortie
  %{time: ~N[2024-09-28 10:00:00], status: true, user_id: 1},   # Saturday - Pointage d'entrée
  %{time: ~N[2024-09-28 19:00:00], status: false, user_id: 1},   # Saturday - Pointage de sortie

  # Week 6
  %{time: ~N[2024-10-03 07:00:00], status: true, user_id: 1},   # Monday - Pointage d'entrée
  %{time: ~N[2024-10-03 19:00:00], status: false, user_id: 1},  # Monday - Pointage de sortie
  %{time: ~N[2024-10-04 07:00:00], status: true, user_id: 1},   # Tuesday - Pointage d'entrée
  %{time: ~N[2024-10-04 19:00:00], status: false, user_id: 1},  # Tuesday - Pointage de sortie
  %{time: ~N[2024-10-05 07:00:00], status: true, user_id: 1},   # Wednesday - Pointage d'entrée
  %{time: ~N[2024-10-05 19:00:00], status: false, user_id: 1},  # Wednesday - Pointage de sortie
  %{time: ~N[2024-10-06 07:00:00], status: true, user_id: 1},   # Thursday - Pointage d'entrée
  %{time: ~N[2024-10-06 19:00:00], status: false, user_id: 1},  # Thursday - Pointage de sortie
  %{time: ~N[2024-10-07 07:00:00], status: true, user_id: 1},   # Friday - Pointage d'entrée
  %{time: ~N[2024-10-07 19:00:00], status: false, user_id: 1},  # Friday - Pointage de sortie
  %{time: ~N[2024-10-08 10:00:00], status: true, user_id: 1},   # Saturday - Pointage d'entrée
  %{time: ~N[2024-10-08 19:00:00], status: false, user_id: 1},  # Saturday - Pointage de sortie

  # Week 7
  %{time: ~N[2024-10-13 07:00:00], status: true, user_id: 1},   # Monday - Pointage d'entrée
  %{time: ~N[2024-10-13 19:00:00], status: false, user_id: 1},  # Monday - Pointage de sortie
  %{time: ~N[2024-10-14 07:00:00], status: true, user_id: 1},   # Tuesday - Pointage d'entrée
  %{time: ~N[2024-10-14 19:00:00], status: false, user_id: 1},  # Tuesday - Pointage de sortie
  %{time: ~N[2024-10-15 07:00:00], status: true, user_id: 1},   # Wednesday - Pointage d'entrée
  %{time: ~N[2024-10-15 19:00:00], status: false, user_id: 1},  # Wednesday - Pointage de sortie
  %{time: ~N[2024-10-16 07:00:00], status: true, user_id: 1},   # Thursday - Pointage d'entrée
  %{time: ~N[2024-10-16 19:00:00], status: false, user_id: 1},  # Thursday - Pointage de sortie
  %{time: ~N[2024-10-17 07:00:00], status: true, user_id: 1},   # Friday - Pointage d'entrée
  %{time: ~N[2024-10-17 19:00:00], status: false, user_id: 1},  # Friday - Pointage de sortie
  %{time: ~N[2024-10-18 10:00:00], status: true, user_id: 1},   # Saturday - Pointage d'entrée
  %{time: ~N[2024-10-18 19:00:00], status: false, user_id: 1}   # Saturday - Pointage de sortie
]

# Loop through each clock attribute
for clock <- clock_attrs do
  case Repo.get_by(Clock, time: clock.time, status: clock.status) do
    nil ->
      %Clock{}
      |> Clock.changeset(clock)
      |> Repo.insert!()

      IO.puts("Clock created successfully.")

    _existing_clock ->
      IO.puts("Clock already exists for this user.")
  end
end


# Define working time attributes for the user
working_time_attrs = [
  # Week 1 (26 août - 01 septembre)
  %{start: ~N[2024-08-26 07:00:00], end: ~N[2024-08-26 16:00:00], user_id: 1}, # Monday
  %{start: ~N[2024-08-27 07:00:00], end: ~N[2024-08-27 16:00:00], user_id: 1}, # Tuesday
  %{start: ~N[2024-08-28 07:00:00], end: ~N[2024-08-28 16:00:00], user_id: 1}, # Wednesday
  %{start: ~N[2024-08-29 07:00:00], end: ~N[2024-08-29 16:00:00], user_id: 1}, # Thursday
  %{start: ~N[2024-08-30 07:00:00], end: ~N[2024-08-30 16:00:00], user_id: 1}, # Friday
  %{start: ~N[2024-08-31 09:00:00], end: ~N[2024-08-31 18:00:00], user_id: 1}, # Saturday

  # Week 2 (02 septembre - 08 septembre)
  %{start: ~N[2024-09-02 08:00:00], end: ~N[2024-09-02 19:00:00], user_id: 1}, # Monday
  %{start: ~N[2024-09-03 08:00:00], end: ~N[2024-09-03 19:00:00], user_id: 1}, # Tuesday
  %{start: ~N[2024-09-04 08:00:00], end: ~N[2024-09-04 19:00:00], user_id: 1}, # Wednesday
  %{start: ~N[2024-09-05 08:00:00], end: ~N[2024-09-05 19:00:00], user_id: 1}, # Thursday
  %{start: ~N[2024-09-06 08:00:00], end: ~N[2024-09-06 19:00:00], user_id: 1}, # Friday
  %{start: ~N[2024-09-07 09:00:00], end: ~N[2024-09-07 18:00:00], user_id: 1}, # Saturday

  # Week 3 (09 septembre - 15 septembre)
  %{start: ~N[2024-09-09 07:00:00], end: ~N[2024-09-09 12:00:00], user_id: 1}, # Monday
  %{start: ~N[2024-09-10 13:00:00], end: ~N[2024-09-10 18:00:00], user_id: 1}, # Tuesday
  %{start: ~N[2024-09-11 07:00:00], end: ~N[2024-09-11 12:00:00], user_id: 1}, # Wednesday
  %{start: ~N[2024-09-12 07:00:00], end: ~N[2024-09-12 12:00:00], user_id: 1}, # Thursday
  %{start: ~N[2024-09-13 07:00:00], end: ~N[2024-09-13 12:00:00], user_id: 1}, # Friday
  %{start: ~N[2024-09-14 09:00:00], end: ~N[2024-09-14 20:00:00], user_id: 1}, # Saturday

  # Week 4 (16 septembre - 22 septembre)
  %{start: ~N[2024-09-16 09:00:00], end: ~N[2024-09-16 20:00:00], user_id: 1}, # Monday
  %{start: ~N[2024-09-17 09:00:00], end: ~N[2024-09-17 20:00:00], user_id: 1}, # Tuesday
  %{start: ~N[2024-09-18 09:00:00], end: ~N[2024-09-18 20:00:00], user_id: 1}, # Wednesday
  %{start: ~N[2024-09-19 09:00:00], end: ~N[2024-09-19 20:00:00], user_id: 1}, # Thursday
  %{start: ~N[2024-09-20 09:00:00], end: ~N[2024-09-20 20:00:00], user_id: 1}, # Friday
  %{start: ~N[2024-09-21 10:00:00], end: ~N[2024-09-21 19:00:00], user_id: 1}, # Saturday

  # Week 5 (23 septembre - 29 septembre)
  %{start: ~N[2024-09-23 07:00:00], end: ~N[2024-09-23 12:00:00], user_id: 1}, # Monday
  %{start: ~N[2024-09-24 07:00:00], end: ~N[2024-09-24 12:00:00], user_id: 1}, # Tuesday
  %{start: ~N[2024-09-25 07:00:00], end: ~N[2024-09-25 12:00:00], user_id: 1}, # Wednesday
  %{start: ~N[2024-09-26 07:00:00], end: ~N[2024-09-26 12:00:00], user_id: 1}, # Thursday
  %{start: ~N[2024-09-27 07:00:00], end: ~N[2024-09-27 12:00:00], user_id: 1}, # Friday

  # Week 6 (30 septembre - 06 octobre)
  %{start: ~N[2024-09-30 02:00:00], end: ~N[2024-09-30 10:00:00], user_id: 1}, # Monday - Night shift
  %{start: ~N[2024-10-01 02:00:00], end: ~N[2024-10-01 10:00:00], user_id: 1}, # Tuesday - Night shift
  %{start: ~N[2024-10-02 07:00:00], end: ~N[2024-10-02 16:00:00], user_id: 1}, # Wednesday
  %{start: ~N[2024-10-03 07:00:00], end: ~N[2024-10-03 16:00:00], user_id: 1}, # Thursday
  %{start: ~N[2024-10-04 07:00:00], end: ~N[2024-10-04 16:00:00], user_id: 1}, # Friday
  %{start: ~N[2024-10-05 10:00:00], end: ~N[2024-10-05 18:00:00], user_id: 1}, # Saturday

  # Week 7 (07 octobre - 13 octobre)
  %{start: ~N[2024-10-07 07:00:00], end: ~N[2024-10-07 16:00:00], user_id: 1}, # Monday
  %{start: ~N[2024-10-08 07:00:00], end: ~N[2024-10-08 16:00:00], user_id: 1}, # Tuesday
  %{start: ~N[2024-10-09 07:00:00], end: ~N[2024-10-09 16:00:00], user_id: 1}, # Wednesday
  %{start: ~N[2024-10-10 07:00:00], end: ~N[2024-10-10 16:00:00], user_id: 1}, # Thursday
  %{start: ~N[2024-10-11 07:00:00], end: ~N[2024-10-11 16:00:00], user_id: 1}, # Friday
  %{start: ~N[2024-10-12 09:00:00], end: ~N[2024-10-12 18:00:00], user_id: 1},  # Saturday

  # Week 8
  %{start: ~N[2024-10-13 07:00:00], end: ~N[2024-10-13 16:00:00], user_id: 1}, # Monday
  %{start: ~N[2024-10-14 07:00:00], end: ~N[2024-10-14 16:00:00], user_id: 1}, # Tuesday
  %{start: ~N[2024-10-15 07:00:00], end: ~N[2024-10-15 16:00:00], user_id: 1}, # Wednesday
  %{start: ~N[2024-10-16 07:00:00], end: ~N[2024-10-16 16:00:00], user_id: 1}, # Thursday
  %{start: ~N[2024-10-17 07:00:00], end: ~N[2024-10-17 16:00:00], user_id: 1}, # Friday
  %{start: ~N[2024-10-18 09:00:00], end: ~N[2024-10-18 18:00:00], user_id: 1}  # Saturday
]

# Insert each working time entry if it doesn't already exist
Enum.each(working_time_attrs, fn working_time_attr ->
  case Repo.get_by(WorkingTime, start: working_time_attr.start, end: working_time_attr.end, user_id: working_time_attr.user_id) do
    nil ->
      %WorkingTime{}
      |> WorkingTime.changeset(working_time_attr)
      |> Repo.insert!()
      IO.puts("Working time created for #{working_time_attr.start}.")
    _ ->
      IO.puts("Working time already exists for #{working_time_attr.start}.")
  end
end)
