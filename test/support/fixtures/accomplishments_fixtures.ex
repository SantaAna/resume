defmodule Resume.AccomplishmentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resume.Accomplishments` context.
  """

  @doc """
  Generate a accomplishment.
  """
  def accomplishment_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        name: "some name"
      })

    {:ok, accomplishment} = Resume.Accomplishments.create_accomplishment(scope, attrs)
    accomplishment
  end
end
