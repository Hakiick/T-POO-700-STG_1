defmodule TimeManager.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email])
    |> validate_required([:username, :email])
    |> validate_email(:email)
    #|> validate_length(:username, min: 3, max: 20)
    #|> validate_length(:email, max: 255)
    #|> unique_constraint(:email)
    #|> unique_constraint(:username)
  end

  defp validate_email(changeset, field) do
    email = get_field(changeset, field)

    if EmailValidator.valid_email?(email) do
      changeset
    else
      add_error(changeset, field, "is not a valid email")
    end
  end
end
