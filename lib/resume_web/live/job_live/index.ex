defmodule ResumeWeb.JobLive.Index do
  use ResumeWeb, :live_view

  alias Resume.Jobs

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Jobs
        <:actions>
          <.button variant="primary" navigate={~p"/jobs/new"}>
            <.icon name="hero-plus" /> New Job
          </.button>
        </:actions>
      </.header>

      <.table
        id="jobs"
        rows={@streams.jobs}
        row_click={fn {_id, job} -> JS.navigate(~p"/jobs/#{job}") end}
      >
        <:col :let={{_id, job}} label="Title">{job.title}</:col>
        <:col :let={{_id, job}} label="Company">{job.company}</:col>
        <:col :let={{_id, job}} label="Start date">{job.start_date}</:col>
        <:col :let={{_id, job}} label="End date">{job.end_date}</:col>
        <:action :let={{_id, job}}>
          <div class="sr-only">
            <.link navigate={~p"/jobs/#{job}"}>Show</.link>
          </div>
          <.link navigate={~p"/jobs/#{job}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, job}}>
          <.link
            phx-click={JS.push("delete", value: %{id: job.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    Jobs.subscribe_jobs(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Listing Jobs")
     |> stream(:jobs, Jobs.list_jobs(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    job = Jobs.get_job!(socket.assigns.current_scope, id)
    {:ok, _} = Jobs.delete_job(socket.assigns.current_scope, job)

    {:noreply, stream_delete(socket, :jobs, job)}
  end

  @impl true
  def handle_info({type, %Resume.Jobs.Job{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :jobs, Jobs.list_jobs(socket.assigns.current_scope), reset: true)}
  end
end
