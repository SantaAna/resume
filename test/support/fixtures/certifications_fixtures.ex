defmodule Resume.CertificationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resume.Certifications` context.
  """

  @doc """
  Generate a certification.
  """
  def certification_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        embedding_content: "some embedding_content",
        last_embedded: ~N[2025-04-30 18:19:00],
        name: "some name"
      })

    {:ok, certification} = Resume.Certifications.create_certification(scope, attrs)
    certification
  end
end
