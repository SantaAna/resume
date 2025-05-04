defmodule Resume.Technologies do
  @moduledoc """
  The Technologies context.
  """

  import Ecto.Query, warn: false
  alias Resume.Repo

  alias Resume.Technologies.Technology
  alias Resume.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any technology changes.

  The broadcasted messages match the pattern:

    * {:created, %Technology{}}
    * {:updated, %Technology{}}
    * {:deleted, %Technology{}}

  """
  def subscribe_technologies(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Resume.PubSub, "user:#{key}:technologies")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Resume.PubSub, "user:#{key}:technologies", message)
  end

  @doc """
  Returns the list of technologies.

  ## Examples

      iex> list_technologies(scope)
      [%Technology{}, ...]

  """
  def list_technologies(%Scope{} = scope) do
    Repo.all(from technology in Technology, where: technology.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single technology.

  Raises `Ecto.NoResultsError` if the Technology does not exist.

  ## Examples

      iex> get_technology!(123)
      %Technology{}

      iex> get_technology!(456)
      ** (Ecto.NoResultsError)

  """
  def get_technology!(%Scope{} = scope, id) do
    Repo.get_by!(Technology, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a technology.

  ## Examples

      iex> create_technology(%{field: value})
      {:ok, %Technology{}}

      iex> create_technology(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_technology(%Scope{} = scope, attrs \\ %{}) do
    with {:ok, technology = %Technology{}} <-
           %Technology{}
           |> Technology.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, technology})
      {:ok, technology}
    end
  end

  @doc """
  Updates a technology.

  ## Examples

      iex> update_technology(technology, %{field: new_value})
      {:ok, %Technology{}}

      iex> update_technology(technology, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_technology(%Scope{} = scope, %Technology{} = technology, attrs) do
    true = technology.user_id == scope.user.id

    with {:ok, technology = %Technology{}} <-
           technology
           |> Technology.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, technology})
      {:ok, technology}
    end
  end

  @doc """
  Deletes a technology.

  ## Examples

      iex> delete_technology(technology)
      {:ok, %Technology{}}

      iex> delete_technology(technology)
      {:error, %Ecto.Changeset{}}

  """
  def delete_technology(%Scope{} = scope, %Technology{} = technology) do
    true = technology.user_id == scope.user.id

    with {:ok, technology = %Technology{}} <-
           Repo.delete(technology) do
      broadcast(scope, {:deleted, technology})
      {:ok, technology}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking technology changes.

  ## Examples

      iex> change_technology(technology)
      %Ecto.Changeset{data: %Technology{}}

  """
  def change_technology(%Scope{} = scope, %Technology{} = technology, attrs \\ %{}) do
    Technology.changeset(technology, attrs, scope)
  end
end
