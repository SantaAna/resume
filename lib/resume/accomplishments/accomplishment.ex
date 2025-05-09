defmodule Resume.Accomplishments.Accomplishment do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %{
          name: String.t(),
          description: String.t(),
          embedding_content: String.t(),
          embedding: Pgvector.Ecto.Vector.t(),
          last_embedded: NaiveDateTime.t(),
          job_id: integer()
        }

  schema "accomplishments" do
    field :name, :string
    field :description, :string
    field :embedding, Pgvector.Ecto.Vector
    field :embedding_content, :string
    field :last_embedded, :naive_datetime
    field :job_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(accomplishment, attrs, user_scope) do
    accomplishment
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end

  @doc """
  Used by job when casting with associated accomplishments.
  """
  def changeset_from_job(accomplishment, attrs) do
    accomplishment
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end

  def embed_changeset(technology, embed_params) do
    technology
    |> cast(embed_params, [:embedding_content, :embedding])
    |> validate_required([:embedding_content, :embedding, :name, :description])
    |> put_change(:last_embedded, Resume.Util.ecto_naive_now())
  end
end
