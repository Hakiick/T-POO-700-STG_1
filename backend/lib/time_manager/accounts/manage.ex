defmodule TimeManager.Accounts.Manage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "manage" do

    field :user_id, :id
    field :team_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(manage, attrs) do
    manage
    |> cast(attrs, [:user_id, :team_id])
    |> validate_required([:user_id, :team_id])
  end
end
