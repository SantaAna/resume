defmodule Resume.Educations do
  @moduledoc """
  The Educations context.
  """

  import Ecto.Query, warn: false
  alias Resume.Repo

  alias Resume.Educations.Education
  alias Resume.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any education changes.

  The broadcasted messages match the pattern:

    * {:created, %Education{}}
    * {:updated, %Education{}}
    * {:deleted, %Education{}}

  """
  def subscribe_educations(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Resume.PubSub, "user:#{key}:educations")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Resume.PubSub, "user:#{key}:educations", message)
  end

  @doc """
  Returns the list of educations.

  ## Examples

      iex> list_educations(scope)
      [%Education{}, ...]

  """
  def list_educations(%Scope{} = scope) do
    Repo.all(from education in Education, where: education.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single education.

  Raises `Ecto.NoResultsError` if the Education does not exist.

  ## Examples

      iex> get_education!(123)
      %Education{}

      iex> get_education!(456)
      ** (Ecto.NoResultsError)

  """
  def get_education!(%Scope{} = scope, id) do
    Repo.get_by!(Education, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a education.

  ## Examples

      iex> create_education(%{field: value})
      {:ok, %Education{}}

      iex> create_education(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_education(%Scope{} = scope, attrs \\ %{}) do
    with {:ok, education = %Education{}} <-
           %Education{}
           |> Education.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, education})
      {:ok, education}
    end
  end

  @doc """
  Updates a education.

  ## Examples

      iex> update_education(education, %{field: new_value})
      {:ok, %Education{}}

      iex> update_education(education, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_education(%Scope{} = scope, %Education{} = education, attrs) do
    true = education.user_id == scope.user.id

    with {:ok, education = %Education{}} <-
           education
           |> Education.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, education})
      {:ok, education}
    end
  end

  @doc """
  Deletes a education.

  ## Examples

      iex> delete_education(education)
      {:ok, %Education{}}

      iex> delete_education(education)
      {:error, %Ecto.Changeset{}}

  """
  def delete_education(%Scope{} = scope, %Education{} = education) do
    true = education.user_id == scope.user.id

    with {:ok, education = %Education{}} <-
           Repo.delete(education) do
      broadcast(scope, {:deleted, education})
      {:ok, education}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking education changes.

  ## Examples

      iex> change_education(education)
      %Ecto.Changeset{data: %Education{}}

  """
  def change_education(%Scope{} = scope, %Education{} = education, attrs \\ %{}) do
    true = education.user_id == scope.user.id

    Education.changeset(education, attrs, scope)
  end
end
