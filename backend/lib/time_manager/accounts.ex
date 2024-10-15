defmodule TimeManager.Accounts do
  use Ecto.Schema
  import Ecto.Changeset

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
    |> cast(attrs, [:username, :email, :password, :role_id, :is_active, :team_id])
    |> validate_required([:username, :email, :password, :role_id, :is_active, :team_id])
  end
end
