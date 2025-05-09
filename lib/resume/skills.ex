defmodule Resume.Skills do
  @moduledoc """
  The Skills context.
  """

  import Ecto.Query, warn: false
  alias Resume.Repo

  alias Resume.Skills.Skill
  alias Resume.Accounts.Scope
  import Resume.Util

  @doc """
  Subscribes to scoped notifications about any skill changes.

  The broadcasted messages match the pattern:

    * {:created, %Skill{}}
    * {:updated, %Skill{}}
    * {:deleted, %Skill{}}

  """
  def subscribe_skills(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Resume.PubSub, "user:#{key}:skills")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Resume.PubSub, "user:#{key}:skills", message)
  end

  @doc """
  Returns the list of skills.

  ## Examples

      iex> list_skills(scope)
      [%Skill{}, ...]

  """
  def list_skills(%Scope{} = scope) do
    Repo.all(from skill in Skill, where: skill.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single skill.

  Raises `Ecto.NoResultsError` if the Skill does not exist.

  ## Examples

      iex> get_skill!(123)
      %Skill{}

      iex> get_skill!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill!(%Scope{} = scope, id) do
    Repo.get_by!(Skill, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a skill.

  ## Examples

      iex> create_skill(%{field: value})
      {:ok, %Skill{}}

      iex> create_skill(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill(%Scope{} = scope, attrs \\ %{}) do
    with {:ok, skill = %Skill{}} <-
           %Skill{}
           |> Skill.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, skill})
      {:ok, skill}
    end
  end

  @doc """
  Updates a skill.

  ## Examples

      iex> update_skill(skill, %{field: new_value})
      {:ok, %Skill{}}

      iex> update_skill(skill, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill(%Scope{} = scope, %Skill{} = skill, attrs) do
    true = skill.user_id == scope.user.id

    with {:ok, skill = %Skill{}} <-
           skill
           |> Skill.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, skill})
      {:ok, skill}
    end
  end

  @doc """
  Deletes a skill.

  ## Examples

      iex> delete_skill(skill)
      {:ok, %Skill{}}

      iex> delete_skill(skill)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill(%Scope{} = scope, %Skill{} = skill) do
    true = skill.user_id == scope.user.id

    with {:ok, skill = %Skill{}} <-
           Repo.delete(skill) do
      broadcast(scope, {:deleted, skill})
      {:ok, skill}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill changes.

  ## Examples

      iex> change_skill(skill)
      %Ecto.Changeset{data: %Skill{}}

  """
  def change_skill(%Scope{} = scope, %Skill{} = skill, attrs \\ %{}) do
    Skill.changeset(skill, attrs, scope)
  end

  def embed_skill(skill = %Skill{name: skill_name, description: skill_description})
      when is_non_empty_binary(skill_name) and is_non_empty_binary(skill_description) do
    with {:ok, embedding_content} <-
           Resume.Inference.create_skill_embed(skill_name, skill_description),
         {:ok, embedding} <-
           Resume.Embedding.Provider.embed(
             Resume.Embedding.Provider.VoyageLite,
             embedding_content,
             input_type: :document
           ) do
      skill
      |> Skill.embed_changeset(%{embedding: embedding, embedding_content: embedding_content})
    end
  end

  def embed_skill(_),
    do: raise(ArgumentError, "Must provide skill with non empty name and description")
end
