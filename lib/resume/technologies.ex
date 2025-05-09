defmodule Resume.TechnologyError do
  @moduledoc """
  Represents an error that has occured while working with technologies. 


  ## Fields
  - `:message` - message to be returned by raise, if not set the message of the exception  
  in the `:reason` field will be used.
  - `:reason` - an `Exception.t()` that is the underlying casue of the inference error. 
  - `:technology` - a `Technology.t()` that was being processed when the error occured.
  """
  defexception [:message, :reason, :technology]

  @type t :: %{
          message: String.t() | nil,
          reason: Exception.t(),
          technology: Resume.Technologies.Technology.t()
        }

  def message(%__MODULE__{message: message}) when not is_nil(message) do
    message
  end

  def message(%__MODULE__{reason: %{__struct__: m, __exception__: true} = reason}) do
    "Caused by #{inspect(m)}: #{Exception.message(reason)}"
  end
end

defmodule Resume.Technologies do
  @moduledoc """
  The Technologies context.
  """

  import Ecto.Query, warn: false
  alias Resume.Repo

  alias Resume.Technologies.Technology
  alias Resume.Accounts.Scope
  alias Resume.TechnologyError
  import Resume.Util

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

  @doc """
  Creates an embedding for a technology using its name and description.

  The function generates embedding content using the technology's name and description,
  then creates an embedding using the VoyageLite provider. The embedding and its content
  are stored with the technology record.

  ## Parameters
    * `technology` - A %Technology{} struct with non-empty name and description fields

  ## Returns
    * `{:ok, %Technology{}}` - The updated technology with embedding data
    * `{:error, Ecto.Changeset.t()}` - If embedding creation fails
    * `{:error, TechnologyError.t()}` - If embedding creation fails
  """
  @spec embed_technology(Technology.t()) ::
          {:ok, Technology.t()} | {:error, Ecto.Changeset.t()} | {:error, TechnologyError.t()}
  def embed_technology(technology = %Technology{name: tech_name, description: tech_description})
      when is_non_empty_binary(tech_name) and is_non_empty_binary(tech_description) do
    with {:ok, embedding_content} <-
           Resume.Inference.create_technology_embed(tech_name, tech_description),
         {:ok, embedding} <-
           Resume.Embedding.Provider.embed(
             Resume.Embedding.Provider.VoyageLite,
             embedding_content,
             input_type: :document
           ) do
      technology
      |> Technology.embed_changeset(%{embedding: embedding, embedding_content: embedding_content})
      |> Repo.update()
    else
      {:error, e} ->
        {:error, %TechnologyError{reason: e, technology: technology}}
    end
  end

  def embed_technology(_),
    do: raise(ArgumentError, "Must provide technology with non empty name and description")

  @doc """
  Updates the embeddings for all technology records.
  If the technology record has been updated since the 
  last embedding it will be re-embedded using the 
  `embed_technology/1` function.
  """
  def update_embeddings() do
    query =
      from(t in Technology,
        where: t.last_embedded < t.last_user_content_update or is_nil(t.last_embedded)
      )

    query
    |> Repo.all()
    |> Enum.map(&embed_technology/1)
  end
end
