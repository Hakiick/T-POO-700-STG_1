defmodule TimeManager.Repo.Migrations.CreateManage do
  use Ecto.Migration

  def change do
    create table(:manage) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :team_id, references(:teams, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:manage, [:user_id, :team_id])
  end
end
