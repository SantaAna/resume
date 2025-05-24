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
  require Logger

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

      {:error, chain, e} ->
        {:error, %InferenceError{reason: e, chain: chain}}
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

  def resume_introduction(user, job_description) do
    start_of_chain()
    |> LLMChain.new!()
    |> LLMChain.add_messages([
      Message.new_system!("""
      You are writing an opening paragraph for a resume.  You should give a brief pitch for then
      candidate targetting a hiring manager.

      Do not make up the example! Use the provided tools to learn more about the candidate.
      Use the web search tool to lookup unfamiliar terms if needed.

      Do not say that the user has done anything at the company they are applying for.


      When the critique_output function gives your paragraph a "good" rating then you are done and can send 
      the paragraph to the user.

      Use the feedback from critique_output to imrpove your paragraph.

      Do not mention the feedback directly in your output
      """),
      Message.new_user!("""
      I'm applying for a job with the job description: #{job_description} please help me write an introduction.
      """)
    ])
    |> LLMChain.add_tools([
      skills_tool(user),
      certifications_tool(user),
      technologies_tool(user),
      accomplishment_tool(user),
      critique_tool(user, job_description),
      search_tool()
    ])
    |> LLMChain.run(mode: :while_needs_response, max_runs: 3)
    |> case do
      {:ok, final_chain} ->
        {:ok, final_chain.last_message.content}

      {:error, chain, e} ->
        {:error, %InferenceError{reason: e, chain: chain}}
    end
  end

  def critique_opening(paragraph, user, job_description) do
    result =
      start_of_chain()
      |> LLMChain.new!()
      |> LLMChain.add_messages([
        Message.new_system!("""
          You are reviewing the opening paragraph for a resume written by an
          overly effusive LLM assitant.  Please read the provided paragraph
          and respond with helpful instructions to improve the LLMs output. If 
          you think the paragraph is good enough reply with OK.

          Do not attempt to rewrite the paragraph, just provide specific fededback.

          Do not provide feedback that could lead LLM assistant to claim to have worked
          at the company they are applying to.
          
          Do not mention any specific number or metric.  Never suggest or use an example
          that contains a specific number or percentage.

          Your target audience is a hiring manager, who you need to interest in the resume 
          so they will continue reading.

          return your output as json with the following format: 
          {
           rating: "terrible" | "bad" | "okay" | "good" | "great",
           feedback: <your feedback text>
          }

          the rating scale is: 
          terrible - sure to be rejected, hard to read
          bad - very likely to be rejected, numerous errors 
          okay - even chance of rejection, some flaws but readable
          good - will stand out from other resumes, writing is concise and strong
          great - excellent composition and will leave a great impression on those who read it.
        """),
        Message.new_user!("""
              Hello please help me improve the following opening paragraph: 

              #{paragraph}

              I'm writing it to apply to the job with the following description:

              #{job_description}
        """)
      ])
      |> LLMChain.add_tools([
        skills_tool(user),
        certifications_tool(user),
        technologies_tool(user),
        accomplishment_tool(user)
      ])
      |> LLMChain.run()

    case result do
      {:ok, final_chain} ->
        {:ok, final_chain.last_message.content}

      {:error, chain, e} ->
        {:error, %InferenceError{reason: e, chain: chain}}
    end
  end

  defp critique_tool(user, job_description) do
    Function.new!(%{
      name: "critique_output",
      description:
        "provides helfpul feedback on your proposed paragraph. Call this with the paragraph you intend to return to the user.",
      parameters: [
        FunctionParam.new!(%{name: "paragraph", type: :string, required: true})
      ],
      function: fn %{"paragraph" => paragraph} = arg, _context ->
        critique_opening(paragraph, user, job_description)
        |> case do
          {:ok, response} ->
            response
            |> IO.inspect(
              label:
                "critique tool called with #{inspect(arg)}, returned the following feedback: "
            )

          {:error, _} = e ->
            e
        end
      end
    })
  end

  defp skills_tool(user) do
    Function.new!(%{
      name: "get_user_skills",
      description:
        "Returns users skills that most closely match your query. Will return JSON in the format [{name: accomplishment_name, description: accomplishment_short_description, long_description: accomplishment_long_descripition}]",
      parameters: [
        FunctionParam.new!(%{name: "query", type: :string, required: true}),
        FunctionParam.new!(%{name: "count", type: :integer})
      ],
      function: fn %{"query" => term} = arg, _context ->
        Logger.info("get_user_skills called with term: #{term}")
        count = Map.get(arg, :count, 3)
        Resume.Skills.top_embeds(user, term, count, :json)
      end
    })
  end

  defp certifications_tool(user) do
    Function.new!(%{
      name: "get_user_certifications",
      description:
        "Returns users certifications that most closely match your query. Will return JSON in the format [{name: certification_name, description: certification_description, long_description: certification_long_description]",
      parameters: [
        FunctionParam.new!(%{name: "query", type: :string, required: true}),
        FunctionParam.new!(%{name: "count", type: :integer})
      ],
      function: fn %{"query" => term} = arg, _context ->
        Logger.info("get_user_technologies called with term: #{term}")
        count = Map.get(arg, :count, 3)
        Resume.Certifications.top_embeds(user, term, count, :json)
      end
    })
  end

  defp technologies_tool(user) do
    Function.new!(%{
      name: "get_user_technologies",
      description:
        "Returns users technologies that most closely match your query. Will return JSON in the format [{name: technology_name, description: technology_description, long_description: technology_long_description]",
      parameters: [
        FunctionParam.new!(%{name: "query", type: :string, required: true}),
        FunctionParam.new!(%{name: "count", type: :integer})
      ],
      function: fn %{"query" => term} = arg, _context ->
        Logger.info("get_user_technologies called with term: #{term}")
        count = Map.get(arg, :count, 3)
        Resume.Technologies.top_embeds(user, term, count, :json)
      end
    })
  end

  defp accomplishment_tool(user) do
    Function.new!(%{
      name: "get_user_accomplishments",
      description:
        "Returns users accomplishments that most closely match your query. Will return JSON in the format [{name: accomplishment_name, description: accomplishment_short_description, long_description: accomplishment_long_descripition}]",
      parameters: [
        FunctionParam.new!(%{name: "query", type: :string, required: true}),
        FunctionParam.new!(%{name: "count", type: :integer})
      ],
      function: fn %{"query" => term} = arg, _context ->
        Logger.info("get_user_accomplishments called with term: #{term}")
        count = Map.get(arg, :count, 3)
        Resume.Accomplishments.top_embeds(user, term, count, :json)
      end
    })
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
  defp start_of_chain(), do: %{llm: ChatOpenAI.new!(%{model: "o4-mini"})}
end
