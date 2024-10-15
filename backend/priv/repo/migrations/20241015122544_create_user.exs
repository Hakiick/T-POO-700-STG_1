defmodule TimeManager.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :username, :string
      add :email, :string
      add :password, :string
      add :role_id, :integer
      add :is_active, :boolean, default: false, null: false
      add :team_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
