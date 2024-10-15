defmodule TimeManager.Repo.Migrations.AddFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :role
      remove :password
      add :role_id, :id, null: true
    end
  end
end
