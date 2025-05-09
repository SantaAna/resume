defmodule Resume.Certifications.Certification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "certifications" do
    field :name, :string
    field :description, :string
    field :embedding_content, :string
    field :last_embedded, :naive_datetime
    field :last_user_content_update, :naive_datetime
    field :embedding, Pgvector.Ecto.Vector
    belongs_to :user, Resume.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(certification, attrs, user_scope) do
    certification
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
    |> put_change(:user_id, user_scope.user.id)
    |> put_change(:last_user_content_update, Resume.Util.ecto_naive_now())
  end
end
