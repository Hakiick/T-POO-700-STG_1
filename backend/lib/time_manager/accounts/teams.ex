defmodule TimeManager.Accounts.Teams do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    field :description, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(teams, attrs) do
    teams
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
