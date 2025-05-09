defmodule Resume.AccomplishmentsError do
  @moduledoc """
  Represents an error that has occured while working with accomplishments. 

  ## Fields
  - `:message` - message to be returned by raise, if not set the message of the exception  
  in the `:reason` field will be used.
  - `:reason` - an `Exception.t()` that is the underlying casue of the inference error. 
  - `:accomplishment` - a `Accomplishment.t()` that was being processed when the error occured.
  """
  defexception [:message, :reason, :accomplishment]

  @type t :: %{
          message: String.t() | nil,
          reason: Exception.t(),
          accomplishment: Resume.Accomplishments.Accomplishment.t()
        }

  def message(%__MODULE__{message: message}) when not is_nil(message) do
    message
  end

  def message(%__MODULE__{reason: %{__struct__: m, __exception__: true} = reason}) do
    "Caused by #{inspect(m)}: #{Exception.message(reason)}"
  end
end

defmodule Resume.Accomplishments do
  @moduledoc """
  The Accomplishments context.
  """

  import Ecto.Query, warn: false
  alias Resume.Repo

  alias Resume.Accomplishments.Accomplishment
  alias Resume.Accounts.Scope
  alias Resume.AccomplishmentsError
  import Resume.Util

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
    Repo.all(
      from accomplishment in Accomplishment, where: accomplishment.user_id == ^scope.user.id
    )
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

  @doc """
  Creates an embedding for an accomplishment using its title and description.

  The function generates embedding content using the accomplishment's title and description,
  then creates an embedding using the VoyageLite provider. The embedding and its content
  are stored with the accomplishment record.

  ## Parameters
    * `accomplishment` - A %Accomplishment{} struct with non-empty title and description fields

  ## Returns
    * `{:ok, %Accomplishment{}}` - The updated accomplishment with embedding data
    * `{:error, term()}` - If embedding creation fails
    * raises `ArgumentError` - If accomplishment title or description is empty
  """
  @spec embed_accomplishment(Accomplishment.t()) ::
          {:ok, Accomplishment.t()}
          | {:error, Ecto.Changeset.t()}
          | {:error, AccomplishmentsError.t()}
  def embed_accomplishment(
        accomplishment = %Accomplishment{name: title, description: description}
      )
      when is_non_empty_binary(title) and is_non_empty_binary(description) do
    with {:ok, embedding_content} <-
           Resume.Inference.create_accomplishment_embed(title, description),
         {:ok, embedding} <-
           Resume.Embedding.Provider.embed(
             Resume.Embedding.Provider.VoyageLite,
             embedding_content,
             input_type: :document
           ) do
      accomplishment
      |> Accomplishment.embed_changeset(%{
        embedding: embedding,
        embedding_content: embedding_content
      })
      |> Repo.update()
    else
      {:error, e} ->
        {:error, %AccomplishmentsError{reason: e, accomplishment: accomplishment}}
    end
  end

  def embed_accomplishment(_),
    do: raise(ArgumentError, "Must provide accomplishment with non empty title and description")

  @doc """
  Updates the embeddings for all accomplishment records.
  If the accomplishment record has been updated since the 
  last embedding it will be re-embedded using the 
  `embed_accomplishment/1` function.
  """
  def update_embeddings() do
    query =
      from(a in Accomplishment,
        where: a.last_embedded < a.last_user_content_update or is_nil(a.last_embedded)
      )

    query
    |> Repo.all()
    |> Enum.map(&embed_accomplishment/1)
  end
end
