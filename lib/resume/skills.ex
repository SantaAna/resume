defmodule Resume.SkillsError do
  @moduledoc """
  Represents an error that has occured while working with skills. 


  ## Fields
  - `:message` - message to be returned by raise, if not set the message of the exception  
  in the `:reason` field will be used.
  - `:reason` - an `Exception.t()` that is the underlying casue of the inference error. 
  - `:skill` - a `Skill.t()` that was being processed when the error occured.
  """
  defexception [:message, :reason, :skill]

  @type t :: %{
          message: String.t() | nil,
          reason: Exception.t(),
          skill: Resume.Skills.Skill.t()
        }

  def message(%__MODULE__{message: message}) when not is_nil(message) do
    message
  end

  def message(%__MODULE__{reason: %{__struct__: m, __exception__: true} = reason}) do
    "Caused by #{inspect(m)}: #{Exception.message(reason)}"
  end
end

defmodule Resume.Skills do
  @moduledoc """
  The Skills context.
  """

  import Ecto.Query, warn: false
  import Pgvector.Ecto.Query, warn: false
  alias Resume.Repo

  alias Resume.Skills.Skill
  alias Resume.Accounts.Scope
  alias Resume.SkillsError
  alias Resume.Accounts.User
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

  @doc """
  Creates an embedding for a skill using its name and description.

  The function generates embedding content using the skill's name and description,
  then creates an embedding using the VoyageLite provider. The embedding and its content
  are stored with the skill record.

  ## Parameters
    * `skill` - A %Skill{} struct with non-empty name and description fields

  ## Returns
    * `{:ok, %Skill{}}` - The updated skill with embedding data
    * `{:error, term()}` - If embedding creation fails
    * raises `ArgumentError` - If skill name or description is empty
  """
  @spec embed_skill(Skill.t()) ::
          {:ok, Skill.t()} | {:error, Ecto.Changeset.t()} | {:error, SkillsError.t()}
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
      |> Repo.update()
    else
      {:error, e} ->
        {:error, %SkillsError{reason: e, skill: skill}}
    end
  end

  def embed_skill(_),
    do: raise(ArgumentError, "Must provide skill with non empty name and description")

  @doc """
  Updates the embeddings for all skill records.
  If the skill record has been updated since the 
  last embedding it will be re-embedded using the 
  `embed_skill/1` function.
  """
  def update_embeddings() do
    query =
      from(s in Skill,
        where: s.last_embedded < s.last_user_content_update or is_nil(s.last_embedded)
      )

    query
    |> Repo.all()
    |> Enum.map(&embed_skill/1)
  end

  @doc """
  Given a `User` struct an `input_string` and a `count` will return
  the `count` closest accomplishments by cosine distance, will 
  return as `return_type`
  """
  @spec top_embeds(user :: map(), input_string :: String.t(), count :: integer(), :map | :json) ::
          {:ok, list(Skill.t())} | {:error, SkillsError.t()}
  def top_embeds(user = %User{}, input_string, count, :map)
      when is_binary(input_string) and is_integer(count) do
    with {:ok, embedding} <-
           Resume.Embedding.Provider.embed(
             Resume.Embedding.Provider.VoyageLite,
             input_string,
             input_type: :document
           ) do
      q =
        from skill in Skill,
          where: skill.user_id == ^user.id,
          order_by: cosine_distance(skill.embedding, ^embedding),
          limit: ^count,
          select: %{
            description: skill.description,
            long_description: skill.embedding_content,
            name: skill.name
          }

      {:ok, Repo.all(q)}
    else
      {:error, e} ->
        {:error, %SkillsError{reason: e}}
    end
  end

  def top_embeds(user = %User{}, input_string, count, :json)
      when is_integer(count) and is_binary(input_string) do
    with {:ok, map_value} <- top_embeds(user, input_string, count, :map) do
      {:ok, JSON.encode!(map_value)}
    end
  end

  def top_embeds(user, input_string, count, output) when is_binary(count) do
    with {count_integer, ""} <- Integer.parse(count) do
      top_embeds(user, input_string, count_integer, output)
    else
      {_, _} ->
        %SkillsError{
          reason: %ArgumentError{
            message: "`top_embeds\4` expects a count argument that represents an integer"
          }
        }
    end
  end
end
