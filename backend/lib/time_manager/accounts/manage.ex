defmodule TimeManager.Accounts.Manage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "manage" do
    belongs_to :team, TimeManager.Accounts.Team
    belongs_to :user, TimeManager.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(manage, attrs) do
    manage
    |> cast(attrs, [:team_id, :user_id])
    |> validate_required([:team_id, :user_id])
  end
end
