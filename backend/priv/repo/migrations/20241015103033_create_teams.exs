defmodule TimeManager.Repo.Migrations.CreateRhTable do
  use Ecto.Migration

  def change do
    create table(:rh) do
      add :user_id, references(:users, on_delete: :nothing)
      add :team_id, references(:teams, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:rh, [:user_id])
    create index(:rh, [:team_id])
  end
end
