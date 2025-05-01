defmodule Resume.Repo.Migrations.CreateEducations do
  use Ecto.Migration

  def change do
    create table(:educations) do
      add :institution, :string
      add :institution_type, :string
      add :diploma_earned, :string
      add :embedding_content, :text
      add :last_embedded, :naive_datetime
      add :embedding, :vector, size: 512
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
