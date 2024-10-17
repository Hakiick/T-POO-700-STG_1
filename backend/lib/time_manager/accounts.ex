defmodule TimeManager.Accounts do
  alias TimeManager.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset
  import Bcrypt
  alias TimeManager.Repo

  schema "user" do
    field :email, :string
    field :is_active, :boolean, default: false
    field :password, :string
    field :role_id, :integer
    field :team_id, :integer
    field :username, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(accounts, attrs) do
    accounts
    |> cast(attrs, [:email, :password, :username, :role_id, :is_active, :team_id])
    |> validate_required([ :email, :password, :username,:role_id, :is_active, :team_id])
  end

  def check_password(%User{} = user, password) do
    Bcrypt.checkpw(password, user.password)
  end

  def create_user(%{"email" => email, "password" => password, "username" => username}) do

    %User{}
    |> User.changeset(%{email: email, password: password, username: username})
    |> Repo.insert()
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end
end
