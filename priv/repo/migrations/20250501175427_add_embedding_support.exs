defmodule Resume.Repo.Migrations.AddEmbeddingSupport do
  use Ecto.Migration

  def change do
    alter table("jobs") do
      add :embedding_content, :text
      add :last_embedded, :naive_datetime
    end

    alter table("accomplishments") do
      add :embedding_content, :text
      add :last_embedded, :naive_datetime
    end

    alter table("skills") do
      add :last_embedded, :naive_datetime
    end

    alter table("technologies") do
      add :last_embedded, :naive_datetime
    end
  end
end
