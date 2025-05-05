defmodule Resume.Search.Provider do
  @doc """
  Submits a query to the search provider.
  Must return either an `:error` tuple or an 
  `:ok` tuple containing the embedding as 
  a list.
  """
  @callback search(query_string :: String.t(), options :: Keyword.t()) ::
              embedding :: {:ok, list(String.t())} | {:error, Exception.t()}

  def search(module, string, opts \\ []) do
    apply(module, :search, [string, opts])
  end
end
