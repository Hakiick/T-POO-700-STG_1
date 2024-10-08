defmodule TimeManager.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email])
    |> validate_required([:username, :email])
    #|> validate_length(:username, min: 3, max: 20)
    #|> validate_length(:email, max: 255)
    |> validate_format(:email, ~r/^[\w.!#$%&’*+/=?`{|}~^-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/)
    #|> unique_constraint(:email)
    #|> unique_constraint(:username)
  end
end
