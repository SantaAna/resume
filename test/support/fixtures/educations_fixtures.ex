defmodule Resume.EducationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resume.Educations` context.
  """

  @doc """
  Generate a education.
  """
  def education_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        diploma_earned: "some diploma_earned",
        embedding_content: "some embedding_content",
        institution: "some institution",
        institution_type: "some institution_type",
        last_embedded: ~N[2025-04-30 18:22:00]
      })

    {:ok, education} = Resume.Educations.create_education(scope, attrs)
    education
  end
end
