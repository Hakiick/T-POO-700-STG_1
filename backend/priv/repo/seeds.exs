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
users_attrs = [
  %{
    username: "Alice",
    email: "alice@example.com",
    password: "ff8d9819fc0e12bf0d24892e45987e249a28dce836a85cad60e28eaaa8c6d976"
  },
  %{
    username: "Bob",
    email: "bob@example.com",
    password: "5ff860bf1190596c7188ab851db691f0f3169c453936e9e1eba2f9a47f7a0018"
  },
  %{
    username: "Charlie",
    email: "charlie@example.com",
    password: "add7232b65bb559f896cbcfa9a600170a7ca381a0366789dcf59ad986bdf4a98"
  },
  %{
    username: "David",
    email: "david@example.com",
    password: "d4e3f52c47a33949241f67af482f562ece6f62e618b041a62d00fa7ba5dae280"
  },
  %{
    username: "Eve",
    email: "eve@example.com",
    password: "d0574c4966d2c326193622feebc64991c5b59807ae68fa8255b26c79f4bf917a"
  }
]

# Insert users into the database
for user_attrs <- users_attrs do
  case Repo.get_by(User, email: user_attrs.email) do
    nil ->
      user = %User{}

      user
      |> User.registration_changeset(user_attrs)
      |> Repo.insert!()

      IO.puts("User #{user_attrs.username} created successfully.")

    _existing_user ->
      IO.puts("User #{user_attrs.username} already exists.")
  end
end

# Define clock attributes for the user
clock_attrs = [
  # Alice (user_id: 1)
  %{user_id: 1, status: true, time: ~N[2024-10-16 08:00:00]},
  %{user_id: 1, status: false, time: ~N[2024-10-16 17:00:00]},
  %{user_id: 1, status: true, time: ~N[2024-10-17 08:15:00]},
  %{user_id: 1, status: false, time: ~N[2024-10-17 16:45:00]},
  %{user_id: 1, status: true, time: ~N[2024-10-18 09:00:00]},
  %{user_id: 1, status: false, time: ~N[2024-10-18 17:30:00]},
  %{user_id: 1, status: true, time: ~N[2024-10-19 07:45:00]},
  %{user_id: 1, status: false, time: ~N[2024-10-19 16:30:00]},
  %{user_id: 1, status: true, time: ~N[2024-10-20 08:10:00]},
  %{user_id: 1, status: false, time: ~N[2024-10-20 17:00:00]},
  %{user_id: 1, status: true, time: ~N[2024-10-21 08:30:00]},
  %{user_id: 1, status: false, time: ~N[2024-10-21 16:45:00]},
  %{user_id: 1, status: true, time: ~N[2024-10-22 09:00:00]},
  %{user_id: 1, status: false, time: ~N[2024-10-22 16:50:00]},

  # Bob (user_id: 2)
  %{user_id: 2, status: true, time: ~N[2024-10-16 08:20:00]},
  %{user_id: 2, status: false, time: ~N[2024-10-16 16:55:00]},
  %{user_id: 2, status: true, time: ~N[2024-10-17 08:10:00]},
  %{user_id: 2, status: false, time: ~N[2024-10-17 16:30:00]},
  %{user_id: 2, status: true, time: ~N[2024-10-18 09:05:00]},
  %{user_id: 2, status: false, time: ~N[2024-10-18 17:40:00]},
  %{user_id: 2, status: true, time: ~N[2024-10-19 07:50:00]},
  %{user_id: 2, status: false, time: ~N[2024-10-19 16:35:00]},
  %{user_id: 2, status: true, time: ~N[2024-10-20 08:25:00]},
  %{user_id: 2, status: false, time: ~N[2024-10-20 17:05:00]},
  %{user_id: 2, status: true, time: ~N[2024-10-21 08:45:00]},
  %{user_id: 2, status: false, time: ~N[2024-10-21 16:50:00]},
  %{user_id: 2, status: true, time: ~N[2024-10-22 09:05:00]},
  %{user_id: 2, status: false, time: ~N[2024-10-22 16:55:00]},

  # Clara (user_id: 3)
  %{user_id: 3, status: true, time: ~N[2024-10-16 08:30:00]},
  %{user_id: 3, status: false, time: ~N[2024-10-16 17:10:00]},
  %{user_id: 3, status: true, time: ~N[2024-10-17 08:25:00]},
  %{user_id: 3, status: false, time: ~N[2024-10-17 16:40:00]},
  %{user_id: 3, status: true, time: ~N[2024-10-18 09:10:00]},
  %{user_id: 3, status: false, time: ~N[2024-10-18 17:35:00]},
  %{user_id: 3, status: true, time: ~N[2024-10-19 07:55:00]},
  %{user_id: 3, status: false, time: ~N[2024-10-19 16:40:00]},
  %{user_id: 3, status: true, time: ~N[2024-10-20 08:35:00]},
  %{user_id: 3, status: false, time: ~N[2024-10-20 17:15:00]},
  %{user_id: 3, status: true, time: ~N[2024-10-21 08:50:00]},
  %{user_id: 3, status: false, time: ~N[2024-10-21 16:55:00]},
  %{user_id: 3, status: true, time: ~N[2024-10-22 09:10:00]},
  %{user_id: 3, status: false, time: ~N[2024-10-22 17:00:00]},

  # David (user_id: 4)
  %{user_id: 4, status: true, time: ~N[2024-10-16 08:30:00]},
  %{user_id: 4, status: false, time: ~N[2024-10-16 17:10:00]},
  %{user_id: 4, status: true, time: ~N[2024-10-17 08:25:00]},
  %{user_id: 4, status: false, time: ~N[2024-10-17 16:40:00]},
  %{user_id: 4, status: true, time: ~N[2024-10-18 09:10:00]},
  %{user_id: 4, status: false, time: ~N[2024-10-18 17:35:00]},
  %{user_id: 4, status: true, time: ~N[2024-10-19 07:55:00]},
  %{user_id: 4, status: false, time: ~N[2024-10-19 16:40:00]},
  %{user_id: 4, status: true, time: ~N[2024-10-20 08:35:00]},
  %{user_id: 4, status: false, time: ~N[2024-10-20 17:15:00]},
  %{user_id: 4, status: true, time: ~N[2024-10-21 08:50:00]},
  %{user_id: 4, status: false, time: ~N[2024-10-21 16:55:00]},
  %{user_id: 4, status: true, time: ~N[2024-10-22 09:10:00]},
  %{user_id: 4, status: false, time: ~N[2024-10-22 17:00:00]},

  # David (user_id: 4)
  %{user_id: 5, status: true, time: ~N[2024-10-16 09:30:00]},
  %{user_id: 5, status: false, time: ~N[2024-10-16 17:10:00]},
  %{user_id: 5, status: true, time: ~N[2024-10-17 09:25:00]},
  %{user_id: 5, status: false, time: ~N[2024-10-17 16:40:00]},
  %{user_id: 5, status: true, time: ~N[2024-10-18 09:10:00]},
  %{user_id: 5, status: false, time: ~N[2024-10-18 17:35:00]},
  %{user_id: 5, status: true, time: ~N[2024-10-19 07:55:00]},
  %{user_id: 5, status: false, time: ~N[2024-10-19 16:40:00]},
  %{user_id: 5, status: true, time: ~N[2024-10-20 08:35:00]},
  %{user_id: 5, status: false, time: ~N[2024-10-20 17:15:00]},
  %{user_id: 5, status: true, time: ~N[2024-10-21 08:50:00]},
  %{user_id: 5, status: false, time: ~N[2024-10-21 16:55:00]},
  %{user_id: 5, status: true, time: ~N[2024-10-22 09:10:00]},
  %{user_id: 5, status: false, time: ~N[2024-10-22 17:00:00]},
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
  # Week 1 (07 octobre - 13 octobre)
  # User 1
  # Monday
  %{start: ~N[2024-10-07 07:00:00], end: ~N[2024-10-07 16:00:00], user_id: 1},
  # Tuesday
  %{start: ~N[2024-10-08 07:00:00], end: ~N[2024-10-08 16:00:00], user_id: 1},
  # Wednesday
  %{start: ~N[2024-10-09 07:00:00], end: ~N[2024-10-09 16:00:00], user_id: 1},
  # Thursday
  %{start: ~N[2024-10-10 07:00:00], end: ~N[2024-10-10 16:00:00], user_id: 1},
  # Friday
  %{start: ~N[2024-10-11 07:00:00], end: ~N[2024-10-11 16:00:00], user_id: 1},
  # Saturday
  %{start: ~N[2024-10-12 09:00:00], end: ~N[2024-10-12 18:00:00], user_id: 1},

  # User 2
  # Monday
  %{start: ~N[2024-10-07 08:00:00], end: ~N[2024-10-07 17:00:00], user_id: 2},
  # Tuesday
  %{start: ~N[2024-10-08 08:00:00], end: ~N[2024-10-08 17:00:00], user_id: 2},
  # Wednesday
  %{start: ~N[2024-10-09 08:00:00], end: ~N[2024-10-09 17:00:00], user_id: 2},
  # Thursday
  %{start: ~N[2024-10-10 08:00:00], end: ~N[2024-10-10 17:00:00], user_id: 2},
  # Friday
  %{start: ~N[2024-10-11 08:00:00], end: ~N[2024-10-11 17:00:00], user_id: 2},
  # Saturday
  %{start: ~N[2024-10-12 10:00:00], end: ~N[2024-10-12 19:00:00], user_id: 2},

  # User 3
  # Monday
  %{start: ~N[2024-10-07 06:30:00], end: ~N[2024-10-07 15:30:00], user_id: 3},
  # Tuesday
  %{start: ~N[2024-10-08 06:30:00], end: ~N[2024-10-08 15:30:00], user_id: 3},
  # Wednesday
  %{start: ~N[2024-10-09 06:30:00], end: ~N[2024-10-09 15:30:00], user_id: 3},
  # Thursday
  %{start: ~N[2024-10-10 06:30:00], end: ~N[2024-10-10 15:30:00], user_id: 3},
  # Friday
  %{start: ~N[2024-10-11 06:30:00], end: ~N[2024-10-11 15:30:00], user_id: 3},
  # Saturday
  %{start: ~N[2024-10-12 08:00:00], end: ~N[2024-10-12 17:00:00], user_id: 3},

  # User 4
  # Monday
  %{start: ~N[2024-10-07 09:00:00], end: ~N[2024-10-07 18:00:00], user_id: 4},
  # Tuesday
  %{start: ~N[2024-10-08 09:00:00], end: ~N[2024-10-08 18:00:00], user_id: 4},
  # Wednesday
  %{start: ~N[2024-10-09 09:00:00], end: ~N[2024-10-09 18:00:00], user_id: 4},
  # Thursday
  %{start: ~N[2024-10-10 09:00:00], end: ~N[2024-10-10 18:00:00], user_id: 4},
  # Friday
  %{start: ~N[2024-10-11 09:00:00], end: ~N[2024-10-11 18:00:00], user_id: 4},
  # Saturday
  %{start: ~N[2024-10-12 11:00:00], end: ~N[2024-10-12 20:00:00], user_id: 4},

  # User 5
  # Monday
  %{start: ~N[2024-10-07 10:00:00], end: ~N[2024-10-07 19:00:00], user_id: 5},
  # Tuesday
  %{start: ~N[2024-10-08 10:00:00], end: ~N[2024-10-08 19:00:00], user_id: 5},
  # Wednesday
  %{start: ~N[2024-10-09 10:00:00], end: ~N[2024-10-09 19:00:00], user_id: 5},
  # Thursday
  %{start: ~N[2024-10-10 10:00:00], end: ~N[2024-10-10 19:00:00], user_id: 5},
  # Friday
  %{start: ~N[2024-10-11 10:00:00], end: ~N[2024-10-11 19:00:00], user_id: 5},
  # Saturday
  %{start: ~N[2024-10-12 12:00:00], end: ~N[2024-10-12 21:00:00], user_id: 5},

  # Week 2 (14 octobre - 20 octobre)
  # User 1
  # Monday
  %{start: ~N[2024-10-14 07:00:00], end: ~N[2024-10-14 16:00:00], user_id: 1},
  # Tuesday
  %{start: ~N[2024-10-15 07:00:00], end: ~N[2024-10-15 16:00:00], user_id: 1},
  # Wednesday
  %{start: ~N[2024-10-16 07:00:00], end: ~N[2024-10-16 16:00:00], user_id: 1},
  # Thursday
  %{start: ~N[2024-10-17 07:00:00], end: ~N[2024-10-17 16:00:00], user_id: 1},
  # Friday
  %{start: ~N[2024-10-18 07:00:00], end: ~N[2024-10-18 16:00:00], user_id: 1},
  # Saturday
  %{start: ~N[2024-10-19 09:00:00], end: ~N[2024-10-19 18:00:00], user_id: 1},

  # User 2
  # Monday
  %{start: ~N[2024-10-14 08:00:00], end: ~N[2024-10-14 17:00:00], user_id: 2},
  # Tuesday
  %{start: ~N[2024-10-15 08:00:00], end: ~N[2024-10-15 17:00:00], user_id: 2},
  # Wednesday
  %{start: ~N[2024-10-16 08:00:00], end: ~N[2024-10-16 17:00:00], user_id: 2},
  # Thursday
  %{start: ~N[2024-10-17 08:00:00], end: ~N[2024-10-17 17:00:00], user_id: 2},
  # Friday
  %{start: ~N[2024-10-18 08:00:00], end: ~N[2024-10-18 17:00:00], user_id: 2},
  # Saturday
  %{start: ~N[2024-10-19 10:00:00], end: ~N[2024-10-19 19:00:00], user_id: 2},

  # User 3
  # Monday
  %{start: ~N[2024-10-14 06:30:00], end: ~N[2024-10-14 15:30:00], user_id: 3},
  # Tuesday
  %{start: ~N[2024-10-15 06:30:00], end: ~N[2024-10-15 15:30:00], user_id: 3},
  # Wednesday
  %{start: ~N[2024-10-16 06:30:00], end: ~N[2024-10-16 15:30:00], user_id: 3},
  # Thursday
  %{start: ~N[2024-10-17 06:30:00], end: ~N[2024-10-17 15:30:00], user_id: 3},
  # Friday
  %{start: ~N[2024-10-18 06:30:00], end: ~N[2024-10-18 15:30:00], user_id: 3},
  # Saturday
  %{start: ~N[2024-10-19 08:00:00], end: ~N[2024-10-19 17:00:00], user_id: 3},

  # User 4
  # Monday
  %{start: ~N[2024-10-14 09:00:00], end: ~N[2024-10-14 18:00:00], user_id: 4},
  # Tuesday
  %{start: ~N[2024-10-15 09:00:00], end: ~N[2024-10-15 18:00:00], user_id: 4},
  # Wednesday
  %{start: ~N[2024-10-16 09:00:00], end: ~N[2024-10-16 18:00:00], user_id: 4},
  # Thursday
  %{start: ~N[2024-10-17 09:00:00], end: ~N[2024-10-17 18:00:00], user_id: 4},
  # Friday
  %{start: ~N[2024-10-18 09:00:00], end: ~N[2024-10-18 18:00:00], user_id: 4},
  # Saturday
  %{start: ~N[2024-10-19 11:00:00], end: ~N[2024-10-19 20:00:00], user_id: 4},

  # User 5
  # Monday
  %{start: ~N[2024-10-14 10:00:00], end: ~N[2024-10-14 19:00:00], user_id: 5},
  # Tuesday
  %{start: ~N[2024-10-15 10:00:00], end: ~N[2024-10-15 19:00:00], user_id: 5},
  # Wednesday
  %{start: ~N[2024-10-16 10:00:00], end: ~N[2024-10-16 19:00:00], user_id: 5},
  # Thursday
  %{start: ~N[2024-10-17 10:00:00], end: ~N[2024-10-17 19:00:00], user_id: 5},
  # Friday
  %{start: ~N[2024-10-18 10:00:00], end: ~N[2024-10-18 19:00:00], user_id: 5},
  # Saturday
  %{start: ~N[2024-10-19 12:00:00], end: ~N[2024-10-19 21:00:00], user_id: 5},

  # Week 3 (21 octobre - 27 octobre)
  # User 1
  # Monday
  %{start: ~N[2024-10-21 07:00:00], end: ~N[2024-10-21 16:00:00], user_id: 1},
  # Tuesday
  %{start: ~N[2024-10-22 07:00:00], end: ~N[2024-10-22 16:00:00], user_id: 1},
  # Wednesday
  %{start: ~N[2024-10-23 07:00:00], end: ~N[2024-10-23 16:00:00], user_id: 1},
  # Thursday
  %{start: ~N[2024-10-24 07:00:00], end: ~N[2024-10-24 16:00:00], user_id: 1},
  # Friday
  %{start: ~N[2024-10-25 07:00:00], end: ~N[2024-10-25 16:00:00], user_id: 1},
  # Saturday
  %{start: ~N[2024-10-26 09:00:00], end: ~N[2024-10-26 18:00:00], user_id: 1},

  # User 2
  # Monday
  %{start: ~N[2024-10-21 08:00:00], end: ~N[2024-10-21 17:00:00], user_id: 2},
  # Tuesday
  %{start: ~N[2024-10-22 08:00:00], end: ~N[2024-10-22 17:00:00], user_id: 2},
  # Wednesday
  %{start: ~N[2024-10-23 08:00:00], end: ~N[2024-10-23 17:00:00], user_id: 2},
  # Thursday
  %{start: ~N[2024-10-24 08:00:00], end: ~N[2024-10-24 17:00:00], user_id: 2},
  # Friday
  %{start: ~N[2024-10-25 08:00:00], end: ~N[2024-10-25 17:00:00], user_id: 2},
  # Saturday
  %{start: ~N[2024-10-26 10:00:00], end: ~N[2024-10-26 19:00:00], user_id: 2},

  # User 3
  # Monday
  %{start: ~N[2024-10-21 06:30:00], end: ~N[2024-10-21 15:30:00], user_id: 3},
  # Tuesday
  %{start: ~N[2024-10-22 06:30:00], end: ~N[2024-10-22 15:30:00], user_id: 3},
  # Wednesday
  %{start: ~N[2024-10-23 06:30:00], end: ~N[2024-10-23 15:30:00], user_id: 3},
  # Thursday
  %{start: ~N[2024-10-24 06:30:00], end: ~N[2024-10-24 15:30:00], user_id: 3},
  # Friday
  %{start: ~N[2024-10-25 06:30:00], end: ~N[2024-10-25 15:30:00], user_id: 3},
  # Saturday
  %{start: ~N[2024-10-26 08:00:00], end: ~N[2024-10-26 17:00:00], user_id: 3},

  # User 4
  # Monday
  %{start: ~N[2024-10-21 09:00:00], end: ~N[2024-10-21 18:00:00], user_id: 4},
  # Tuesday
  %{start: ~N[2024-10-22 09:00:00], end: ~N[2024-10-22 18:00:00], user_id: 4},
  # Wednesday
  %{start: ~N[2024-10-23 09:00:00], end: ~N[2024-10-23 18:00:00], user_id: 4},
  # Thursday
  %{start: ~N[2024-10-24 09:00:00], end: ~N[2024-10-24 18:00:00], user_id: 4},
  # Friday
  %{start: ~N[2024-10-25 09:00:00], end: ~N[2024-10-25 18:00:00], user_id: 4},
  # Saturday
  %{start: ~N[2024-10-26 11:00:00], end: ~N[2024-10-26 20:00:00], user_id: 4},

  # User 5
  # Monday
  %{start: ~N[2024-10-21 10:00:00], end: ~N[2024-10-21 19:00:00], user_id: 5},
  # Tuesday
  %{start: ~N[2024-10-22 10:00:00], end: ~N[2024-10-22 19:00:00], user_id: 5},
  # Wednesday
  %{start: ~N[2024-10-23 10:00:00], end: ~N[2024-10-23 19:00:00], user_id: 5},
  # Thursday
  %{start: ~N[2024-10-24 10:00:00], end: ~N[2024-10-24 19:00:00], user_id: 5},
  # Friday
  %{start: ~N[2024-10-25 10:00:00], end: ~N[2024-10-25 19:00:00], user_id: 5},
  # Saturday
  %{start: ~N[2024-10-26 12:00:00], end: ~N[2024-10-26 21:00:00], user_id: 5}
]

# Insert each working time entry if it doesn't already exist
Enum.each(working_time_attrs, fn working_time_attr ->
  case Repo.get_by(WorkingTime,
         start: working_time_attr.start,
         end: working_time_attr.end,
         user_id: working_time_attr.user_id
       ) do
    nil ->
      %WorkingTime{}
      |> WorkingTime.changeset(working_time_attr)
      |> Repo.insert!()

      IO.puts("Working time created for #{working_time_attr.start}.")

    _ ->
      IO.puts("Working time already exists for #{working_time_attr.start}.")
  end
end)
