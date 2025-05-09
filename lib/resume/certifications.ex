defmodule Resume.CertificationsError do
  @moduledoc """
  Represents an error that has occured while working with certifications. 
  ## Fields
  - `:message` - message to be returned by raise, if not set the message of the exception  
  in the `:reason` field will be used.
  - `:reason` - an `Exception.t()` that is the underlying casue of the inference error. 
  - `:certification` - a `Certification.t()` that was being processed when the error occured.
  """
  defexception [:message, :reason, :certification]

  @type t :: %{
          message: String.t() | nil,
          reason: Exception.t(),
          certification: Resume.Certifications.Certification.t()
        }

  def message(%__MODULE__{message: message}) when not is_nil(message) do
    message
  end

  def message(%__MODULE__{reason: %{__struct__: m, __exception__: true} = reason}) do
    "Caused by #{inspect(m)}: #{Exception.message(reason)}"
  end
end

defmodule Resume.Certifications do
  @moduledoc """
  The Certifications context.
  """

  import Ecto.Query, warn: false
  alias Resume.Repo

  alias Resume.Certifications.Certification
  alias Resume.Accounts.Scope
  alias Resume.CertificationsError
  import Resume.Util

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

  @doc """
  Creates an embedding for a certification using its name and description.

  The function generates embedding content using the certification's name and description,
  then creates an embedding using the VoyageLite provider. The embedding and its content
  are stored with the certification record.

  ## Parameters
    * `certification` - A %Certification{} struct with non-empty name and description fields

  ## Returns
    * `{:ok, %Certification{}}` - The updated certification with embedding data
    * `{:error, term()}` - If embedding creation fails
    * raises `ArgumentError` - If certification name or description is empty
  """
  @spec embed_certification(Certification.t()) ::
          {:ok, Certification.t()}
          | {:error, Ecto.Changeset.t()}
          | {:error, CertificationsError.t()}
  def embed_certification(certification = %Certification{name: name, description: description})
      when is_non_empty_binary(name) and is_non_empty_binary(description) do
    with {:ok, embedding_content} <-
           Resume.Inference.create_certification_embed(name, description),
         {:ok, embedding} <-
           Resume.Embedding.Provider.embed(
             Resume.Embedding.Provider.VoyageLite,
             embedding_content,
             input_type: :document
           ) do
      certification
      |> Certification.embed_changeset(%{
        embedding: embedding,
        embedding_content: embedding_content
      })
      |> Repo.update()
    else
      {:error, e} ->
        {:error, %CertificationsError{reason: e, certification: certification}}
    end
  end

  def embed_certification(_),
    do: raise(ArgumentError, "Must provide certification with non empty name and description")

  @doc """
  Updates the embeddings for all certification records.
  If the certification record has been updated since the 
  last embedding it will be re-embedded using the 
  `embed_certification/1` function.
  """
  def update_embeddings() do
    query =
      from(c in Certification,
        where: c.last_embedded < c.last_user_content_update or is_nil(c.last_embedded)
      )

    query
    |> Repo.all()
    |> Enum.map(&embed_certification/1)
  end
end
