defmodule TimeManager.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, :string
    field :username, :string
    field :role_id, :id
    field :is_active, :boolean, default: true
    field :team_id, :id
    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password, :email, :role_id, :is_active, :team_id])
    |> validate_required([:password, :email])
    |> validate_length(:username, min: 3, max: 30)
    |> validate_length(:email, max: 255)
        # |> validate_format(:email, ~r/^[\w.!#$%&’*+\/=?`{|}~^-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/)
    # |> validate_format(:email, ~r/^[\w\-\.]+@([\w-]+\.)+[\w-]{2,}$/)
    |> unique_constraint(:email)
    |> unique_constraint(:password)
    |> unique_constraint(:username)
    # Ajoutez ici d'autres validations si nécessaire
  end
    # defp validate_email(changeset, field) do
  #   email = get_field(changeset, field)
  #
  #   if EmailValidator.valid_email?(email) do
  #     changeset
  #   else
  #     add_error(changeset, field, "is not a valid email")
  #   end
  # end
end
