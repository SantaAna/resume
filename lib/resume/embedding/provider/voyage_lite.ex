defmodule Resume.Embedding.Provider.VoyageLite do
  @behaviour Resume.Embedding.Provider
  @moduledoc """
  Embedding implementation for VoyageLite 
  embedding model provided by Voyage AI.
  """
  import Resume.Util

  @embed_options NimbleOptions.new!(
                   input_type: [
                     type: {:in, [:document, :query, nil]},
                     default: nil,
                     doc:
                       "determines how the input will be embedded. nil will embed without any customization"
                   ],
                   truncation: [
                     type: :boolean,
                     default: true,
                     doc: "if true will shorten input to match max token"
                   ]
                 )

  @doc """
  Submits embedding request to the VoyageAI lite model.
  ### Options

  #{NimbleOptions.docs(@embed_options)}
  """
  @impl true
  def embed(input, options \\ [])

  def embed(input, options) when is_non_empty_binary(input) do
    opts = NimbleOptions.validate!(options, @embed_options)

    Req.new(
      method: :post,
      url: url(),
      auth: {:bearer, get_api_key()},
      json: prep_body(input, opts[:input_type], opts[:truncation])
    )
    |> Req.Request.put_header("content-type", "application/json")
    |> Req.Request.append_response_steps(check_status: &check_status/1)
    |> Req.Request.append_response_steps(extract_embedding: &extract_embedding/1)
    |> Req.Request.append_response_steps(embedding_missing: &embedding_missing/1)
    |> Req.request()
    |> case do
      {:ok, %{embedding: e}} -> {:ok, e}
      {:error, _} = e -> e
    end
  end

  def embed(input, _) do
    raise ArgumentError, "Expected input to be a string but received: #{inspect(input)}"
  end

  defp embedding_missing({request, %{embedding: embedding} = response}) when is_list(embedding),
    do: {request, response}

  defp embedding_missing({request, _}),
    do: {request, RuntimeError.exception("no embedding returned")}

  defp extract_embedding({request, response}) do
    {request,
     Map.put(response, :embedding, get_in(response.body, ["data", Access.at(0), "embedding"]))}
  end

  defp check_status({request, response}) do
    if response.status == 200 do
      {request, response}
    else
      {request, RuntimeError.exception("invalid response from endpoint")}
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

  defp url() do
    "https://api.voyageai.com/v1/embeddings"
  end

  defp model_name() do
    "voyage-3-lite"
  end

  defp get_api_key() do
    Application.get_env(:resume, :voyage_key)
  end
end
