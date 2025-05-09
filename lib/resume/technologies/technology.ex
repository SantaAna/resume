defmodule Resume.Technologies.Technology do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %{
          name: String.t(),
          description: String.t(),
          embedding_content: String.t(),
          embedding: list(),
          last_embedded: NaiveDateTime.t(),
          last_user_content_update: NaiveDateTime.t()
        }

  schema "technologies" do
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
  def changeset(technology, attrs, user_scope) do
    technology
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
    |> put_change(:user_id, user_scope.user.id)
    |> put_change(:last_user_content_update, Resume.Util.ecto_naive_now())
  end

  def embed_changeset(technology, embed_params) do
    technology
    |> cast(embed_params, [:embedding_content, :embedding])
    |> validate_required([:embedding_content, :embedding, :name, :description, :user_id])
    |> put_change(:last_embedded, Resume.Util.ecto_naive_now())
  end
end
