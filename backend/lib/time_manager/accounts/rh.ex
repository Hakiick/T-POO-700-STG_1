defmodule TimeManager.Accounts.Rh do
  use Ecto.Schema
  import Ecto.Changeset




  schema "rh" do
    field :name, :string
    field :user_id, :id
    field :team_id, :id
    timestamps(type: :utc_datetime)
  end

  def changeset(rh, attrs) do
    rh
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 50)
    |> validate_length(:position, min: 3, max: 50)
    |> validate_length(:department, min: 3, max: 50)
    # Ajoutez ici d'autres validations si nécessaire
  end
end
