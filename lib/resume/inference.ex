defmodule Resume.InferenceError do
  @moduledoc """
  Represents an error that has occured while generating an inferecnce.

  ## Fields
  - `:message` - message to be returned by raise, if not set the message of the exception  
  in the `:reason` field will be used.
  - `:reason` - an `Exception.t()` that is the underlying casue of the inference error. 
  - `:chain` - the llm chain that was running when the error ocured.
  """
  defexception [:message, :reason, :chain]

  @type t :: %{
          message: String.t() | nil,
          reason: Exception.t(),
          chain: LangChain.Chains.LLMChain.t()
        }

  def message(%__MODULE__{message: message}) when not is_nil(message) do
    message
  end

  def message(%__MODULE__{reason: %{__struct__: m, __exception__: true} = reason}) do
    "Caused by #{inspect(m)}: #{Exception.message(reason)}"
  end
end

defmodule Resume.Inference do
  @moduledoc """
  Functions for producing inferences from OpenAI
  """

  alias LangChain.{
          Function,
          Message,
          Chains.LLMChain,
          ChatModels.ChatOpenAI,
          Utils.ChainResult,
          FunctionParam
        },
        warn: false

  alias Resume.Search
  alias Resume.InferenceError

  @doc """
  Produces embedding for the given `cert_name` with 
  `cert_description`
  """
  @spec create_certification_embed(cert_name :: String.t(), cert_user_description :: String.t()) ::
          {:ok, String.t()} | {:error, InferenceError.t()}
  def create_certification_embed(cert_name, cert_user_description) do
    start_of_chain()
    |> LLMChain.new!()
    |> LLMChain.add_messages([
      Message.new_system!(embedding_system_message("cert")),
      Message.new_user!(
        embedding_user_message(
          "cert",
          cert_name,
          cert_user_description
        )
      )
    ])
    |> LLMChain.add_tools([
      search_tool()
    ])
    |> LLMChain.run(mode: :while_needs_response)
    |> case do
      {:ok, final_chain} ->
        {:ok, final_chain.last_message.content}

      {:error, chain, e} ->
        {:error, %InferenceError{reason: e, chain: chain}}
    end
  end

  @doc """
  Produces embedding for the given `skill_name` with 
  `skill_description`
  """

  @spec create_skill_embed(skill_name :: String.t(), skill_user_description :: String.t()) ::
          {:ok, String.t()} | {:error, InferenceError.t()}
  def create_skill_embed(skill_name, skill_user_description) do
    start_of_chain()
    |> LLMChain.new!()
    |> LLMChain.add_messages([
      Message.new_system!(embedding_system_message("skill")),
      Message.new_user!(
        embedding_user_message(
          "skill",
          skill_name,
          skill_user_description
        )
      )
    ])
    |> LLMChain.add_tools([
      search_tool()
    ])
    |> LLMChain.run(mode: :while_needs_response)
    |> case do
      {:ok, final_chain} ->
        {:ok, final_chain.last_message.content}

      {:error, chain, e} ->
        {:error, %InferenceError{reason: e, chain: chain}}
    end
  end

  @doc """
  Produces embedding for the given `technology` with 
  `technology_description`
  """
  @spec create_technology_embed(
          technology_name :: String.t(),
          technology_description :: String.t()
        ) :: {:ok, String.t()} | {:error, InferenceError.t()}
  def create_technology_embed(technology_name, technology_description) do
    start_of_chain()
    |> LLMChain.new!()
    |> LLMChain.add_messages([
      Message.new_system!(embedding_system_message("technology")),
      Message.new_user!(
        embedding_user_message(
          "technology",
          technology_name,
          technology_description
        )
      )
    ])
    |> LLMChain.add_tools([
      search_tool()
    ])
    |> LLMChain.run(mode: :while_needs_response)
    |> case do
      {:ok, final_chain} ->
        {:ok, final_chain.last_message.content}

      {:error, e} ->
        {:error, %InferenceError{reason: e}}
    end
  end

  @doc """
  Produces embedding for the given `education` with 
  `institution_type` and `diploma_earned`
  """
  @spec create_education_embed(
          institution_name :: String.t(),
          institution_type :: String.t(),
          diploma_earned :: String.t()
        ) :: {:ok, String.t()} | {:error, InferenceError.t()}
  def create_education_embed(institution_name, institution_type, diploma_earned) do
    start_of_chain()
    |> LLMChain.new!()
    |> LLMChain.add_messages([
      Message.new_system!(
        embedding_system_message(
          "#{institution_type} called #{institution_name} granting a #{diploma_earned}"
        )
      ),
      Message.new_user!("""
      The institution name is #{institution_name} and it is of the type #{institution_type}.
      Describe the signficance of earning a #{diploma_earned} from this institution.
      Search the internet for more infomration about the diploma and/or institution if needed.
      """)
    ])
    |> LLMChain.add_tools([search_tool()])
    |> LLMChain.run(mode: :while_needs_response)
    |> case do
      {:ok, final_chain} ->
        {:ok, final_chain.last_message.content}

      {:error, chain, e} ->
        {:error, %InferenceError{reason: e, chain: chain}}
    end
  end

  @doc """
  Produces embedding for the given `accomplishment` with 
  `accomplishment_descripiton`. 
  """
  @spec create_accomplishment_embed(
          accomplishment__name :: String.t(),
          accomplishment_description :: String.t()
        ) :: {:ok, embedding :: String.t()} | {:error, InferenceError.t()}
  def create_accomplishment_embed(accomplishment_name, accomplishment_description) do
    start_of_chain()
    |> LLMChain.new!()
    |> LLMChain.add_messages([
      Message.new_system!(embedding_system_message("workplace accomplishments")),
      Message.new_user!("""
      Describe the workplace accomplishment #{accomplishment_name}, 
      given the description: #{accomplishment_description}
      Search the internet with the provided tool if needed.
      """)
    ])
    |> LLMChain.add_tools([search_tool()])
    |> LLMChain.run(mode: :while_needs_response)
    |> case do
      {:ok, final_chain} ->
        {:ok, final_chain.last_message.content}

      {:error, chain, e} ->
        {:error, %InferenceError{reason: e, chain: chain}}
    end
  end

  # defines a search tool that can be called by the
  # language model to look up unfamiliar terms
  defp search_tool() do
    Function.new!(%{
      name: "web_search_term",
      description: "Returns web search results defining a given term.",
      parameters: [FunctionParam.new!(%{name: "term", type: :string, required: true})],
      function: fn %{"term" => term} = _arg, _context ->
        case Search.Provider.search(Search.Providers.LangSearch, term, count: 1, summary: true) do
          {:error, e} -> {:error, e}
          {:ok, list} -> Enum.join(list, "next_result: ")
        end
      end
    })
  end

  # default embedding user message
  defp embedding_user_message(target, target_name, target_description),
    do: """
          Write a short description for a #{target} called: #{target_name}.  
          I would describe it as: #{target_description}.  
          Search the internet using provided function if needed.
    """

  # default embedding system message
  defp embedding_system_message(description_target),
    do: """
    You are assisting in making short descriptions of #{description_target} for a resume.
    Your description should be no more than three sentences long.
    Your decription should be targetted at a recruiter or hiring manager reading a resume.
    Use the description that the user would use along results from using available tools.
    """

  # used to start langchain
  defp start_of_chain(), do: %{llm: ChatOpenAI.new!(%{model: "gpt-4"})}
end
