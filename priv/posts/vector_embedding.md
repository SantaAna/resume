%{
  title: "Vector Embedding with Postgres and Elixir",
  date: "2025-04-30",
  id: "4",
  tags: ~w(elixir postgres llm public frontpage), 
  summary: "Using Postgres and Elixir for Vector embedding and search"
}
---

Vector embedding allows us to search through a vector space representing the semantic content of text, and it's straightforward to implement using postgres with a single extension.  Semantic search can be superior to full-text search, especially in cases where the query is made without any knowledge of what text a desired entry should contain.

In this post we will be using postgres in combination with Elixir and Ecto to implement vector embedding and search.  We will be working with a user skills database which is a good fit for semantic search, after all if you knew exactly what skill could address your problem you probably wouldn't need any type of search at all. 

## What is an Embedding?

An embedding is a representation of the semantic content of text in a high dimensional vector.  By embedding multiple texts in the same embedding (vector) space we can transform the hard problem of analyzing what two pieces of text mean and how alike they are into calculating the distance between two vectors.

Of course this presupposes that we have a way of mapping text into our embedding space that preserves the "meaning" of the text.  This is where embedding services like OpenAI and Voyage come into the picture.  They've developed methods for mapping text into embedding spaces that **seem** to preserve meaning and allow for comparison of texts.

## [pgvector](https://github.com/pgvector/pgvector?tab=readme-ov-file#apt)

Once we have mapped our text into vectors we are going to want to compare them, and hopefully query and rank them by their similarity to each other or to some text query.  There are special purpose vector DBs optimized for these queries, but, as with most things database, [you can just use postgres](https://www.amazingcto.com/postgres-for-everything/).

The first step is to [install postgres and the pgvector](https://github.com/pgvector/pgvector?tab=readme-ov-file#additional-installation-methods) extension on your machine or the container you are running your Elixir app in. 

Assuming you already have an Elixir application with an [ecto repo configured](https://hexdocs.pm/ecto/getting-started.html#setting-up-the-database) you can run `mix ecto.migrate create_pg_vector_extension` and add: 

```elixir
defmodule YourApp.Repo.Migrations.CreatePgVectorExtension do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS vector"
  end

  def down do
    execute "DROP EXTENSION vector"
  end
end
```
After running `mix ecto.migrate` the extension will be installed, but you need to tell ecto how to understand vector types. To do this install the pgvector mix package and add the types it provides to the ecto Repo running in your application:

```elixir
# Mix.exs
defp deps do [
  {:pgvector, "~> 0.3.0"}
]

# your_app/lib/postgrex_types.ex
Postgrex.Types.define(
  Resume.PostgrexTypes,
  Pgvector.extensions() ++ Ecto.Adapters.Postgres.extensions()
)
```
The second part **must** be done it's own file.  `define/2` is a macro that will create a module to append Pgvector's custom types to the ecto's default postgres types.

## Embedding Services

Before we can start storing and searching vectors in our repo we need to choose an embedding provider and vector size.  All embeddings need to be of the same size and use the same embedding model to be comparable.                                The size of the vector will determine how "fine grained" its results will be, the bigger the vector the more "nuanced" the embedding results.  It will also determine how much space is used to store embeddings and how quickly similarity search will run.  

I've chosen [voyage-3.5-lite](https://docs.voyageai.com/docs/embeddings) with a vector size of 1024.  The context size is larger than OpenAI's and in my experience the API returns results quickly.

In my case I created a simple behaviour for implementing an embedding provider.  For now all we need is an embed function to be implemented.

```elixir

defmodule App.Embedding.Provider do
  @doc """
  Submits the input string to be embedded.
  Must return either an `:error` tuple or an 
  `:ok` tuple containing the embedding as 
  a list.
  """
  @callback embed(input :: String.t(), options :: Keyword.t()) ::
              embedding :: {:ok, list(integer() | float())} | {:error, Exception.t()}

  def embed(module, string, opts \\ []) do
    apply(module, :embed, [string, opts])
  end
end
```

Callers can use the `embed/3` function by providing a module that implements the behaviour as the first argument.  This makes switching providers easier to do in the application code, but you would still need to re-embed your data.

Voyage has libraries for Python and TypeScript, but the [REST API](https://docs.voyageai.com/docs/embeddings) is so simple I don't think it would be worth bringing in a dependency.  In Elixir you can get a simple embedding client setup using the req HTTP library: 

```elixir
defmodule App.Embedding.Provider.VoyageLite do
  @behaviour App.Embedding.Provider
  @impl true
  def embed(input, options) when is_non_empty_binary(input) do
    opts = NimbleOptions.validate!(options, @embed_options)

    Req.new(
      method: :post,
      url: url(),
      auth: {:bearer, get_api_key()},
      json: prep_body(input, opts[:input_type], opts[:truncation]),
      retry: :transient
    )
    |> Req.Request.put_header("content-type", "application/json")
    |> Req.Request.append_response_steps(check_status: &check_status/1)
    |> Req.Request.append_response_steps(extract_embedding: &extract_embedding/1)
    |> Req.Request.append_response_steps(embedding_missing: &embedding_missing/1)
    |> Req.request()
    |> case do
      {:ok, %{embedding: e}} ->
        {:ok, e}

      {:error, e} ->
        {:error, %VoyageLiteError{reason: e}}
    end
  end

  defp prep_body(body, input_type, truncate?) when is_binary(body) do
    %{
      input: [body],
      model: model_name(),
      truncation: truncate?,
      input_type: input_type || nil
    }
  end
end
```

## Schemas 

Now we can create schemas that make use of our embeddings. Remember, embeddings are translations of **text** into an embedding space. Structured data like JSON or XML will not, in my experience, embed as well as markdown or flat text.  I'm not a vector wizard, but I think that just the fact that input is in JSON or XML nudges the vector in a structured text direction adding noise to the signal provided by the semantic content.

With that in mind each schema I store in the database has an embedding_content field that describes the row in markdown or plaintext and can be used to generate embeddings.

```elixir
defmodule App.Skills.Skill do
  use Ecto.Schema
  import Ecto.Changeset

  schema "skills" do
    field :name, :string
    field :description, :string
    field :embedding_content, :string
    #Pgvector.Ecto.Vector implements the ecto type 
    #for embedding vectors
    field :embedding, Pgvector.Ecto.Vector
    field :last_embedded, :naive_datetime
    field :last_user_content_update, :naive_datetime
    belongs_to :user, Resume.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(skill, attrs, user_scope) do
    skill
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
    |> put_change(:user_id, user_scope.user.id)
    # insert a timestamp indicating user content has changed
    |> put_change(:last_user_content_update, App.Util.ecto_naive_now())
  end

  def embed_changeset(skill, embed_params) do
    skill
    |> cast(embed_params, [:embedding_content, :embedding])
    |> validate_required([:embedding_content, :embedding, :name, :description, :user_id])
    #insert a timestamp indicating when record was last 
    #embedded
    |> put_change(:last_embedded, App.Util.ecto_naive_now())
  end
```
In the example above let's say we have a database containing user skills.  By comparing the `:last_user_content_update` field with the `:last_embedded` timestamp we can find records that should have embeddings generated. 

```elixir

defmodule App.Skills do
  def update_embeddings() do
    query =
      from(s in Skill,
        where: s.last_embedded < s.last_user_content_update or is_nil(s.last_embedded)
      )

    query
    |> Repo.all()
    |> Enum.map(&embed_skill/1)
  end

  def embed_skill(skill = %Skill{name: skill_name, description: skill_description})
      when is_non_empty_binary(skill_name) and is_non_empty_binary(skill_description) do
    with {:ok, embedding_content} <-
           #We us an LLM to generate our embedding content.
           App.Inference.create_skill_embed(skill_name, skill_description),
         {:ok, embedding} <-
           App.Embedding.Provider.embed(
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
```

In the code above I'm using an LLM to expand upon the data given by the user to create an embedding document.  I've found this to be helpful, especially if the LLM has access to a tool to search the internet for more context on the skill.  This probably comes with a risk of over-fitting, but the results have been positive for me so far.

Now we just need a way to search our table for records that most closely match our a text input:

```elixir
  def top_embeds(user = %User{}, input_string, count, :map)
      when is_binary(input_string) and is_integer(count) do
    with {:ok, embedding} <-
           App.Embedding.Provider.embed(
             App.Embedding.Provider.VoyageLite,
             input_string,
             input_type: :document
           ) do
      q =
        from skill in Skill,
          where: skill.user_id == ^user.id,
          #using cosine distance to determine vector      
          #similarity
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
```
Note that we need to call back to our embedding provider to embed our search term before querying the DB.  This introduces delay, and a change of failure to queries that make use of vector search.

In our query we are using the simplest possible comparison method to determine vector similarity: cosine distance.  In essence this is just a dot product from Linear Algebra 101, reducing the two vectors to a single scalar value indicating how much of one vector lies along the other.  A value of 0 indicates orthogonal vectors, 1 vectors pointing the same direction, -1 pointing the opposite direction.

Now we can search our database for users who had the skills needed to "fix an IP network" and get results for users skilled in "routing and switching" rather than "social networking" or "IP litigation".
