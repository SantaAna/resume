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
  }

  alias Resume.Search

  def basic(input) do
    {:ok, updated_chain} =
      %{llm: ChatOpenAI.new!(%{model: "gpt-4"})}
      |> LLMChain.new!()
      |> LLMChain.add_messages([
        Message.new_system!("You can only answer in rhymes"),
        Message.new_user!(input)
      ])
      |> LLMChain.run()

    updated_chain.last_message.content
  end

  def create_certification_embed(cert_name, cert_user_description) do
    {:ok, final_chain} =
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

    final_chain.last_message.content
  end

  def create_skill_embed(skill_name, skill_user_description) do
    {:ok, final_chain} =
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

    final_chain.last_message.content
  end

  def create_education_embed(institution_name, institution_type, diploma_earned) do
    {:ok, final_chain} =
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

    final_chain.last_message.content
  end

  def create_accomplishment_embed(accomplishment_name, accomplishment_description) do
    {:ok, final_chain} =
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

    final_chain.last_message.content
  end

  def search_tool() do
    Function.new!(%{
      name: "web_search_term",
      description: "Returns web search results defining a given term.",
      parameters: [FunctionParam.new!(%{name: "term", type: :string, required: true})],
      function: fn %{"term" => term} = _arg, _context ->
        Search.Provider.search(Search.Providers.LangSearch, term, count: 1, summary: true)
        |> Enum.join("next result: ")
      end
    })
  end

  defp get_search_info(target, target_name, opts \\ [count: 1, summary: true]) do
    Search.Provider.search(
      Search.Providers.LangSearch,
      "What is the #{target} #{target_name}?",
      opts
    )
  end

  defp embedding_user_message(target, target_name, target_description),
    do: """
          Write a short description for a #{target} called: #{target_name}.  
          I would describe it as: #{target_description}.  
          Search the internet using provided function if needed.
    """

  defp embedding_system_message(description_target),
    do: """
    You are assisting in making short descriptions of #{description_target} for a resume.
    Your description should be no more than three sentences long.
    Your decription should be targetted at a recruiter or hiring manager reading a resume.
    Use the description that the user would use along with the internet search 
    results provided to write your short summary.
    """

  defp start_of_chain(), do: %{llm: ChatOpenAI.new!(%{model: "gpt-4"}), verbose: true}
end
