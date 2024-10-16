defmodule TimeManager.Repo.Migrations.CreateManageTable do
  use Ecto.Migration

  def change do
    create table(:manage) do
      add :team_id, references(:teams, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
  end
end
