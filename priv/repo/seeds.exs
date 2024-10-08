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
