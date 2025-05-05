defmodule Resume.Embedding.Provider do
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
