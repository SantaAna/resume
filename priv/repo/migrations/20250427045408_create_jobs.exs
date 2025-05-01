defmodule Resume.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :title, :string
      add :company, :string
      add :start_date, :date
      add :end_date, :date
      add :embedding, :vector, size: 512
      add :user_id, references("users")

      timestamps(type: :utc_datetime)
    end
  end
end
