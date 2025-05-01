defmodule ResumeWeb.JobLive.Show do
  use ResumeWeb, :live_view

  alias Resume.Jobs

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Job {@job.id}
        <:subtitle>This is a job record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/jobs"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/jobs/#{@job}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit job
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@job.title}</:item>
        <:item title="Company">{@job.company}</:item>
        <:item title="Start date">{@job.start_date}</:item>
        <:item title="End date">{@job.end_date}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    Jobs.subscribe_jobs(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Show Job")
     |> assign(:job, Jobs.get_job!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Resume.Jobs.Job{id: id} = job},
        %{assigns: %{job: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :job, job)}
  end

  def handle_info(
        {:deleted, %Resume.Jobs.Job{id: id}},
        %{assigns: %{job: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current job was deleted.")
     |> push_navigate(to: ~p"/jobs")}
  end
end
