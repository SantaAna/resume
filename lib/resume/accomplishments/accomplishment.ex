defmodule Resume.Accomplishments.Accomplishment do
  use Ecto.Schema
  import Ecto.Changeset

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
end
