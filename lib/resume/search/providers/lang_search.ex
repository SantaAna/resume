defmodule Resume.Search.Providers.LangSearch.Exception do
  defexception [:message, :request, :response]

  def exception(message) when is_binary(message) do
    %__MODULE__{
      message: message
    }
  end

  def exception(list) when is_list(list) do
    struct!(__MODULE__, list)
  end
end

defmodule Resume.Search.Providers.LangSearch do
  @moduledoc """
  An API built to provide context to LLMs.

  [docs](https://docs.langsearch.com/api/web-search-api)
  """

  @search_options NimbleOptions.new!(
                    freshness: [
                      type: {:in, [:one_day, :one_week, :one_month, :one_year, :no_limit]},
                      default: :no_limit,
                      doc: "the freshness for results."
                    ],
                    summary: [
                      type: :boolean,
                      default: false,
                      doc:
                        "whether to create long text summaries.  If this is set to true then the summaries will be returned"
                    ],
                    count: [
                      type: {:in, 1..10},
                      default: 10,
                      doc: "the number of results to return"
                    ],
                    max_length: [
                      type: {:or, [:integer, nil]},
                      default: 500,
                      doc:
                        "the number of characters that will be taken from the search result. If set to `nil` then no limit is applied"
                    ]
                  )
  @doc """
  Submits a query to be searched.

  ## Options
  #{NimbleOptions.docs(@search_options)}
  """
  def search(query, options \\ []) do
    opts = NimbleOptions.validate!(options, @search_options)

    Req.new(
      method: :post,
      url: url(),
      auth: {:bearer, get_api_key()},
      json: prep_body(query, opts)
    )
    |> Req.Request.put_header("content-type", "application/json")
    |> Req.Request.append_request_steps(
      stash_options: &Req.Request.put_private(&1, :options, opts)
    )
    |> Req.Request.append_response_steps(
      check_status: &check_status/1,
      extract_results: &extract_results/1,
      maybe_trim: &maybe_trim_response/1
    )
    |> Req.request()
    |> case do
      {:ok, resp} -> {:ok, Req.Response.get_private(resp, :to_return)}
      {:error, _} = e -> e
    end
  end

  defp check_status({request, %{status: 200} = response}) do
    {request, response}
  end

  defp check_status({request, response}) do
    {request,
     __MODULE__.Exception.exception(
       message: "bad response code",
       request: request,
       response: response
     )}
  end

  defp maybe_trim_response({request, response}) do
    results = Req.Response.get_private(response, :to_return)
    options = Req.Request.get_private(request, :options)

    new_results =
      if max = options[:max_length] do
        results
        |> Enum.map(&String.slice(&1, 0..max))
      else
        results
      end

    {request, Req.Response.put_private(response, :to_return, new_results)}
  end

  defp extract_results({request, response}) do
    values = response.body["data"]["webPages"]["value"]

    results =
      if request.private.options[:summary] do
        Enum.map(values, & &1["summary"])
      else
        Enum.map(values, & &1["snippet"])
      end

    {request, Req.Response.put_private(response, :to_return, results)}
  end

  # opts must be the same shape as `@search_options`
  defp prep_body(query, opts) do
    fresh_value =
      %{
        one_day: "oneDay",
        one_week: "oneWeek",
        one_month: "oneMonth",
        one_year: "oneYear",
        no_limit: "noLimit"
      }
      |> Map.fetch!(opts[:freshness])

    %{
      query: query,
      freshness: fresh_value,
      summary: opts[:summary],
      count: opts[:count]
    }
  end

  def url() do
    "https://api.langsearch.com/v1/web-search"
  end

  def get_api_key() do
    Application.get_env(:resume, :langsearch_key)
  end
end
