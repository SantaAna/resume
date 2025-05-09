defmodule Resume.Technologies.Technology do
  use Ecto.Schema
  import Ecto.Changeset

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
end
