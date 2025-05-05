defmodule ResumeWeb.ComponentsLive.JobForm do
  @moduledoc """
  Live component for adding and managing existing jobs.

  ## Attributes
  - current_scope: requires the default scope.
  """

  use ResumeWeb, :live_component
  alias Resume.Jobs

  def update(assigns, socket) do
    jobs = Jobs.list_jobs_with_accomplishments(assigns.current_scope)

    socket
    |> assign(current_scope: assigns.current_scope)
    |> stream(:jobs, jobs)
    |> fresh_socket()
    |> then(&{:ok, &1})
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} id="job-form" phx-change="validate" phx-submit="save" phx-target={@myself}>
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:company]} type="text" label="Company" />
        <.input field={@form[:start_date]} type="date" label="Start date" />
        <.input field={@form[:end_date]} type="date" label="End date" />
        <h3 class="text-primary-content font-semi-bold mb-2">Accomplishments</h3>
        <.inputs_for :let={accomp} field={@form[:accomplishments]}>
          <div class="relative bg-base-300 p-4  rounded-sm mt-6">
            <input type="hidden" name="job[accomp_sort][]" value={accomp.index} />
            <.input type="text" field={accomp[:name]} label="name" />
            <.input type="text" field={accomp[:description]} label="description" />
            <input type="hidden" name={"job[accomplishments][#{accomp.index}][sub_accomp_drop][]"} />
            <button
              type="button"
              name="job[accomp_drop][]"
              value={accomp.index}
              class="btn btn-secondary w-8 h-8 rounded-full absolute -top-3 -right-2"
              phx-click={JS.dispatch("change")}
            >
              <.icon name="hero-x-mark-solid" class="h-4 w-4 p-2" />
            </button>
          </div>
        </.inputs_for>
        <input type="hidden" name="job[accomp_drop][]" />
        <button
          type="button"
          name="job[accomp_sort][]"
          value="new"
          class="btn w-45 my-4"
          phx-click={JS.dispatch("change")}
        >
          Add Accomplishment
        </button>
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Job</.button>
        </footer>
      </.form>
      <.job_table
        jobs={@streams.jobs}
        delete_action="job-deleted"
        edit_action="job-edit"
        disable_edit={@action == :edit}
        target={@myself}
      />
    </div>
    """
  end

  def handle_event("validate", %{"job" => job_params} = _params, socket) do
    changeset =
      Jobs.change_with_all_children(socket.assigns.current_scope, socket.assigns.job, job_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"job" => job_params}, socket) do
    handle_job(socket, socket.assigns.action, job_params)
  end

  def handle_event("job-deleted", %{"jobid" => id}, socket) do
    job = Jobs.get_job!(socket.assigns.current_scope, id)
    {:ok, _} = Jobs.delete_job(socket.assigns.current_scope, job)

    socket
    |> stream_delete(:jobs, job)
    |> then(&{:noreply, &1})
  end

  def handle_event("job-edit", %{"jobid" => id}, socket) do
    job = Jobs.get_job!(socket.assigns.current_scope, id, [:accomplishments])

    socket
    |> stream_delete(:jobs, job)
    |> assign(
      :form,
      to_form(Jobs.change_with_all_children(socket.assigns.current_scope, job))
    )
    |> assign(:job, job)
    |> assign(:action, :edit)
    |> then(&{:noreply, &1})
  end

  defp handle_job(socket, :new, params) do
    case Jobs.create_job(socket.assigns.current_scope, params) do
      {:ok, job} ->
        {:noreply, socket |> stream_insert(:jobs, job) |> fresh_socket()}

      {:error, cs} ->
        {:noreply, assign(socket, form: to_form(cs))}
    end
  end

  defp handle_job(socket, :edit, params) do
    case Jobs.update_job(
           socket.assigns.current_scope,
           socket.assigns.job,
           params
         ) do
      {:ok, job} ->
        {:noreply, socket |> stream_insert(:jobs, job) |> fresh_socket()}

      {:error, cs} ->
        {:noreply, assign(socket, form: to_form(cs))}
    end
  end

  # preps socket with blank education and form, and action set to new.
  defp fresh_socket(socket) do
    socket
    |> assign(
      job: %Jobs.Job{},
      form:
        to_form(
          Jobs.change_with_all_children(
            socket.assigns.current_scope,
            %Jobs.Job{}
          )
        ),
      action: :new
    )
  end
end
