defmodule Resume.Accomplishments do
  @moduledoc """
  The Accomplishments context.
  """

  import Ecto.Query, warn: false
  alias Resume.Repo

  alias Resume.Accomplishments.Accomplishment
  alias Resume.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any accomplishment changes.

  The broadcasted messages match the pattern:

    * {:created, %Accomplishment{}}
    * {:updated, %Accomplishment{}}
    * {:deleted, %Accomplishment{}}

  """
  def subscribe_accomplishments(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Resume.PubSub, "user:#{key}:accomplishments")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Resume.PubSub, "user:#{key}:accomplishments", message)
  end

  @doc """
  Returns the list of accomplishments.

  ## Examples

      iex> list_accomplishments(scope)
      [%Accomplishment{}, ...]

  """
  def list_accomplishments(%Scope{} = scope) do
    Repo.all(from accomplishment in Accomplishment, where: accomplishment.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single accomplishment.

  Raises `Ecto.NoResultsError` if the Accomplishment does not exist.

  ## Examples

      iex> get_accomplishment!(123)
      %Accomplishment{}

      iex> get_accomplishment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_accomplishment!(%Scope{} = scope, id) do
    Repo.get_by!(Accomplishment, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a accomplishment.

  ## Examples

      iex> create_accomplishment(%{field: value})
      {:ok, %Accomplishment{}}

      iex> create_accomplishment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_accomplishment(%Scope{} = scope, attrs \\ %{}) do
    with {:ok, accomplishment = %Accomplishment{}} <-
           %Accomplishment{}
           |> Accomplishment.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, accomplishment})
      {:ok, accomplishment}
    end
  end

  @doc """
  Updates a accomplishment.

  ## Examples

      iex> update_accomplishment(accomplishment, %{field: new_value})
      {:ok, %Accomplishment{}}

      iex> update_accomplishment(accomplishment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_accomplishment(%Scope{} = scope, %Accomplishment{} = accomplishment, attrs) do
    true = accomplishment.user_id == scope.user.id

    with {:ok, accomplishment = %Accomplishment{}} <-
           accomplishment
           |> Accomplishment.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, accomplishment})
      {:ok, accomplishment}
    end
  end

  @doc """
  Deletes a accomplishment.

  ## Examples

      iex> delete_accomplishment(accomplishment)
      {:ok, %Accomplishment{}}

      iex> delete_accomplishment(accomplishment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_accomplishment(%Scope{} = scope, %Accomplishment{} = accomplishment) do
    true = accomplishment.user_id == scope.user.id

    with {:ok, accomplishment = %Accomplishment{}} <-
           Repo.delete(accomplishment) do
      broadcast(scope, {:deleted, accomplishment})
      {:ok, accomplishment}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking accomplishment changes.

  ## Examples

      iex> change_accomplishment(accomplishment)
      %Ecto.Changeset{data: %Accomplishment{}}

  """
  def change_accomplishment(%Scope{} = scope, %Accomplishment{} = accomplishment, attrs \\ %{}) do
    true = accomplishment.user_id == scope.user.id

    Accomplishment.changeset(accomplishment, attrs, scope)
  end
end
