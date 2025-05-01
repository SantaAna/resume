defmodule Resume.SkillsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resume.Skills` context.
  """

  @doc """
  Generate a skill.
  """
  def skill_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        embedding_content: "some embedding_content",
        name: "some name"
      })

    {:ok, skill} = Resume.Skills.create_skill(scope, attrs)
    skill
  end
end
