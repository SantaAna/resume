defmodule Resume.JobsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resume.Jobs` context.
  """

  @doc """
  Generate a job.
  """
  def job_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        company: "some company",
        end_date: ~D[2025-04-26],
        start_date: ~D[2025-04-26],
        title: "some title"
      })

    {:ok, job} = Resume.Jobs.create_job(scope, attrs)
    job
  end
end
