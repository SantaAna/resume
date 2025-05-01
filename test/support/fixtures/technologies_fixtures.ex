defmodule Resume.TechnologiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resume.Technologies` context.
  """

  @doc """
  Generate a technology.
  """
  def technology_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        embedding_content: "some embedding_content",
        name: "some name"
      })

    {:ok, technology} = Resume.Technologies.create_technology(scope, attrs)
    technology
  end
end
