defmodule Resume.Educations.Education do
  use Ecto.Schema
  import Ecto.Changeset

  schema "educations" do
    field :institution, :string
    field :institution_type, :string
    field :diploma_earned, :string
    field :embedding_content, :string
    field :last_embedded, :naive_datetime
    belongs_to :user, Resume.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(education, attrs, user_scope) do
    education
    |> cast(attrs, [
      :institution,
      :institution_type,
      :diploma_earned
    ])
    |> validate_required([
      :institution,
      :institution_type,
      :diploma_earned
    ])
    |> put_change(:user_id, user_scope.user.id)
  end
end
