defmodule Resume.Jobs do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  alias Resume.Repo

  alias Resume.Jobs.Job
  alias Resume.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any job changes.

  The broadcasted messages match the pattern:

    * {:created, %Job{}}
    * {:updated, %Job{}}
    * {:deleted, %Job{}}

  """
  def subscribe_jobs(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Resume.PubSub, "user:#{key}:jobs")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Resume.PubSub, "user:#{key}:jobs", message)
  end

  @doc """
  Returns the list of jobs.

  ## Examples

      iex> list_jobs(scope)
      [%Job{}, ...]

  """
  def list_jobs(%Scope{} = scope) do
    Repo.all(Job)
  end

  @doc """
  Gets a single job.

  Raises `Ecto.NoResultsError` if the Job does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

      iex> get_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job!(%Scope{} = scope, id) do
    Repo.get_by!(Job, id: id)
  end

  @doc """
  Creates a job.

  ## Examples

      iex> create_job(%{field: value})
      {:ok, %Job{}}

      iex> create_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job(%Scope{} = scope, attrs \\ %{}) do
    with {:ok, job = %Job{}} <-
           %Job{}
           |> Job.all_in_one_changeset(attrs)
           |> Repo.insert() do
      broadcast(scope, {:created, job})
      {:ok, job}
    end
  end

  @doc """
  Updates a job.

  ## Examples

      iex> update_job(job, %{field: new_value})
      {:ok, %Job{}}

      iex> update_job(job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job(%Job{} = job, attrs) do
    with {:ok, job = %Job{}} <-
           job
           |> Job.all_in_one_changeset(attrs)
           |> Repo.update() do
      {:ok, job}
    end
  end

  @doc """
  Deletes a job.

  ## Examples

      iex> delete_job(job)
      {:ok, %Job{}}

      iex> delete_job(job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job(%Scope{} = scope, %Job{} = job) do
    true = job.user_id == scope.user.id

    with {:ok, job = %Job{}} <-
           Repo.delete(job) do
      broadcast(scope, {:deleted, job})
      {:ok, job}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job changes.

  ## Examples

      iex> change_job(job)
      %Ecto.Changeset{data: %Job{}}

  """
  def change_job(%Scope{} = scope, %Job{} = job, attrs \\ %{}) do
    # true = job.user_id == scope.user.id

    Job.changeset(job, attrs, scope)
  end

  @doc """
  Creates a changeset that will create achievements and 
  sub-acheivements
  """
  def change_with_all_children(%Job{} = job, attrs \\ %{}) do
    Job.all_in_one_changeset(job, attrs)
  end
end
