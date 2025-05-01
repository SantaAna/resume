defmodule Resume.Repo.Migrations.CreateSkills do
  use Ecto.Migration

  def change do
    create table(:skills) do
      add :name, :string
      add :description, :string
      add :embedding_content, :text
      add :embedding, :vector, size: 512
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:skills, [:user_id])
  end
end
