defmodule TimeManager.Repo.Migrations.CreateManage do
  use Ecto.Migration

  def change do
    create table(:manage) do
      add :user_id, references(:users, on_delete: :nothing)
      add :team_id, references(:teams, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:manage, [:user_id, :team_id])
  end
end
