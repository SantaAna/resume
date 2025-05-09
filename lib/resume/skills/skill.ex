defmodule Resume.Skills.Skill do
  use Ecto.Schema
  import Ecto.Changeset

  schema "skills" do
    field :name, :string
    field :description, :string
    field :embedding_content, :string
    field :embedding, Pgvector.Ecto.Vector
    field :last_embedded, :naive_datetime
    field :last_user_content_update, :naive_datetime
    belongs_to :user, Resume.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(skill, attrs, user_scope) do
    skill
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
    |> put_change(:user_id, user_scope.user.id)
    |> put_change(:last_user_content_update, Resume.Util.ecto_naive_now())
  end

  def embed_changeset(skill, embed_params) do
    skill
    |> cast(embed_params, [:embedding_content, :embedding])
    |> validate_required([:embedding_content, :embedding, :name, :description, :user_id])
    |> put_change(:last_embedded, Resume.Util.ecto_naive_now())
  end
end
