defmodule Resume.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset
  import Resume.Validations

  schema "jobs" do
    field :title, :string
    field :company, :string
    field :start_date, :date
    field :end_date, :date
    field :embedding_content, :string
    field :last_embedded, :naive_datetime
    field :embedding, Pgvector.Ecto.Vector
    belongs_to :user, Resume.Accounts.User
    has_many :accomplishments, Resume.Accomplishments.Accomplishment, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(job, attrs, user_scope) do
    job
    |> cast(attrs, [:title, :company, :start_date, :end_date])
    |> validate_required([:title, :company, :start_date, :end_date])
    |> validate_before(:start_date, :end_date)
  end

  def all_in_one_changeset(job, attrs, user_scope) do
    job
    |> cast(attrs, [:title, :company, :start_date, :end_date])
    |> validate_required([:title, :company, :start_date, :end_date])
    |> validate_before(:start_date, :end_date)
    |> cast_assoc(:accomplishments,
      with: &Resume.Accomplishments.Accomplishment.changeset_from_job/2,
      sort_param: :accomp_sort,
      drop_param: :accomp_drop
    )
    |> put_change(:user_id, user_scope.user.id)
  end
end
