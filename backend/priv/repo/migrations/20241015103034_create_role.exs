defmodule TimeManager.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string
      # Add other fields as necessary
      timestamps(type: :utc_datetime)
    end
  end
end
