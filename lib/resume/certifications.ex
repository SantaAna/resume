defmodule Resume.Certifications do
  @moduledoc """
  The Certifications context.
  """

  import Ecto.Query, warn: false
  alias Resume.Repo

  alias Resume.Certifications.Certification
  alias Resume.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any certification changes.

  The broadcasted messages match the pattern:

    * {:created, %Certification{}}
    * {:updated, %Certification{}}
    * {:deleted, %Certification{}}

  """
  def subscribe_certifications(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Resume.PubSub, "user:#{key}:certifications")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Resume.PubSub, "user:#{key}:certifications", message)
  end

  @doc """
  Returns the list of certifications.

  ## Examples

      iex> list_certifications(scope)
      [%Certification{}, ...]

  """
  def list_certifications(%Scope{} = scope) do
    Repo.all(from certification in Certification, where: certification.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single certification.

  Raises `Ecto.NoResultsError` if the Certification does not exist.

  ## Examples

      iex> get_certification!(123)
      %Certification{}

      iex> get_certification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_certification!(%Scope{} = scope, id) do
    Repo.get_by!(Certification, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a certification.

  ## Examples

      iex> create_certification(%{field: value})
      {:ok, %Certification{}}

      iex> create_certification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_certification(%Scope{} = scope, attrs \\ %{}) do
    with {:ok, certification = %Certification{}} <-
           %Certification{}
           |> Certification.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, certification})
      {:ok, certification}
    end
  end

  @doc """
  Updates a certification.

  ## Examples

      iex> update_certification(certification, %{field: new_value})
      {:ok, %Certification{}}

      iex> update_certification(certification, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_certification(%Scope{} = scope, %Certification{} = certification, attrs) do
    true = certification.user_id == scope.user.id

    with {:ok, certification = %Certification{}} <-
           certification
           |> Certification.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, certification})
      {:ok, certification}
    end
  end

  @doc """
  Deletes a certification.

  ## Examples

      iex> delete_certification(certification)
      {:ok, %Certification{}}

      iex> delete_certification(certification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_certification(%Scope{} = scope, %Certification{} = certification) do
    true = certification.user_id == scope.user.id

    with {:ok, certification = %Certification{}} <-
           Repo.delete(certification) do
      broadcast(scope, {:deleted, certification})
      {:ok, certification}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking certification changes.

  ## Examples

      iex> change_certification(certification)
      %Ecto.Changeset{data: %Certification{}}

  """
  def change_certification(%Scope{} = scope, %Certification{} = certification, attrs \\ %{}) do
    Certification.changeset(certification, attrs, scope)
  end
end
