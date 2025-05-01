defmodule Resume.Skills.Skill do
  use Ecto.Schema
  import Ecto.Changeset

  schema "skills" do
    field :name, :string
    field :description, :string
    field :embedding_content, :string
    field :embedding, Pgvector.Ecto.Vector
    field :last_embedded, :naive_datetime
    belongs_to :user, Resume.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(skill, attrs, user_scope) do
    skill
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
    |> put_change(:user_id, user_scope.user.id)
  end
end
