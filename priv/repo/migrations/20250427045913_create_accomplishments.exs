defmodule Resume.Repo.Migrations.CreateAccomplishments do
  use Ecto.Migration

  def change do
    create table(:accomplishments) do
      add :name, :string
      add :description, :string
      add :embedding, :vector, size: 512
      add :job_id, references(:jobs, on_delete: :delete_all)
      timestamps(type: :utc_datetime)
    end
  end
end
