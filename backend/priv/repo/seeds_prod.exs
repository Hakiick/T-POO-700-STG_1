alias TimeManager.Repo
alias TimeManager.Accounts.User

# Only seed if no users exist
if Repo.aggregate(User, :count) == 0 do
  # Create a general manager
  {:ok, _} =
    TimeManager.Accounts.register_user(%{
      email: "admin@timemanager.dev",
      password: "Admin123!secure",
      username: "admin",
      role: "general_manager"
    })

  # Create a manager
  {:ok, _} =
    TimeManager.Accounts.register_user(%{
      email: "manager@timemanager.dev",
      password: "Manager123!secure",
      username: "manager",
      role: "manager"
    })

  # Create regular users
  for {email, username} <- [
        {"alice@timemanager.dev", "alice"},
        {"bob@timemanager.dev", "bob"},
        {"charlie@timemanager.dev", "charlie"}
      ] do
    {:ok, _} =
      TimeManager.Accounts.register_user(%{
        email: email,
        password: "User123!secure",
        username: username,
        role: "user"
      })
  end

  IO.puts("Seed data inserted: 1 general_manager, 1 manager, 3 users")
else
  IO.puts("Users already exist, skipping seed")
end
