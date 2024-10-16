defmodule TimeManager.Repo.Migrations.AddFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password, :string
      add :role_id, :id, null: true
      add :is_active, :boolean, default: true
      add team_id, references(:teams, on_delete: :nothing)
      add :role_id, references(:roles, on_delete: :nothing)
    end
  end
end
