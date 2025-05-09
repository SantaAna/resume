defmodule Resume.Repo.Migrations.AddContentTimestamp do
  use Ecto.Migration

  # last user content update field added so we
  # can compare this date to last_embedded to 
  # determine whether a new embedding should be 
  # generated
  def change do
    alter table("skills") do
      add :last_user_content_update, :naive_datetime, null: false
    end

    alter table("technologies") do
      add :last_user_content_update, :naive_datetime, null: false
    end

    alter table("educations") do
      add :last_user_content_update, :naive_datetime, null: false
    end

    alter table("certifications") do
      add :last_user_content_update, :naive_datetime, null: false
    end

    alter table("accomplishments") do
      add :last_user_content_update, :naive_datetime, null: false
    end
  end
end
