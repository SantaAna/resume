defmodule Resume.Repo.Migrations.CreateTechnologies do
  use Ecto.Migration

  def change do
    create table(:technologies) do
      add :name, :string
      add :description, :string
      add :embedding_content, :text
      add :embedding, :vector, size: 512
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
