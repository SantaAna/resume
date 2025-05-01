defmodule ResumeWeb.JobLiveTest do
  use ResumeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resume.JobsFixtures

  @create_attrs %{title: "some title", company: "some company", start_date: "2025-04-26", end_date: "2025-04-26"}
  @update_attrs %{title: "some updated title", company: "some updated company", start_date: "2025-04-27", end_date: "2025-04-27"}
  @invalid_attrs %{title: nil, company: nil, start_date: nil, end_date: nil}

  setup :register_and_log_in_user

  defp create_job(%{scope: scope}) do
    job = job_fixture(scope)

    %{job: job}
  end

  describe "Index" do
    setup [:create_job]

    test "lists all jobs", %{conn: conn, job: job} do
      {:ok, _index_live, html} = live(conn, ~p"/jobs")

      assert html =~ "Listing Jobs"
      assert html =~ job.title
    end

    test "saves new job", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/jobs")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Job")
               |> render_click()
               |> follow_redirect(conn, ~p"/jobs/new")

      assert render(form_live) =~ "New Job"

      assert form_live
             |> form("#job-form", job: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#job-form", job: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/jobs")

      html = render(index_live)
      assert html =~ "Job created successfully"
      assert html =~ "some title"
    end

    test "updates job in listing", %{conn: conn, job: job} do
      {:ok, index_live, _html} = live(conn, ~p"/jobs")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#jobs-#{job.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/jobs/#{job}/edit")

      assert render(form_live) =~ "Edit Job"

      assert form_live
             |> form("#job-form", job: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#job-form", job: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/jobs")

      html = render(index_live)
      assert html =~ "Job updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes job in listing", %{conn: conn, job: job} do
      {:ok, index_live, _html} = live(conn, ~p"/jobs")

      assert index_live |> element("#jobs-#{job.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#jobs-#{job.id}")
    end
  end

  describe "Show" do
    setup [:create_job]

    test "displays job", %{conn: conn, job: job} do
      {:ok, _show_live, html} = live(conn, ~p"/jobs/#{job}")

      assert html =~ "Show Job"
      assert html =~ job.title
    end

    test "updates job and returns to show", %{conn: conn, job: job} do
      {:ok, show_live, _html} = live(conn, ~p"/jobs/#{job}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/jobs/#{job}/edit?return_to=show")

      assert render(form_live) =~ "Edit Job"

      assert form_live
             |> form("#job-form", job: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#job-form", job: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/jobs/#{job}")

      html = render(show_live)
      assert html =~ "Job updated successfully"
      assert html =~ "some updated title"
    end
  end
end
