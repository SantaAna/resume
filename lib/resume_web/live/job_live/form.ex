defmodule ResumeWeb.JobLive.Form do
  use ResumeWeb, :live_view

  alias Resume.Jobs
  alias Resume.Jobs.Job

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage job records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="job-form" phx-change="validate" phx-submit="save">
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
          <.button navigate={return_path(@current_scope, @return_to, @job)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    job = Jobs.get_job!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Job")
    |> assign(:job, job)
    |> assign(:form, to_form(Jobs.change_with_all_children(job)))
  end

  defp apply_action(socket, :new, _params) do
    job = %Job{}

    socket
    |> assign(:page_title, "New Job")
    |> assign(:job, job)
    |> assign(:form, to_form(Jobs.change_with_all_children(job)))
  end

  # def handle_event(
  #       "validate",
  #       %{"job" => job_params, "accomplishments" => accomp_params} = full_params,
  #       socket
  #     ) do
  #   {accomp_key, sub_accomp_params} = pop_accomplishment(accomp_params)
  #
  #   job_params =
  #     update_in(job_params, ["accomplishments", accomp_key], &Map.merge(&1, sub_accomp_params))
  #
  #   IO.inspect(job_params, label: "merged job params")
  #   changeset = Jobs.change_with_all_children(socket.assigns.job, job_params)
  #   {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  # end

  @impl true
  def handle_event("validate", %{"job" => job_params} = full_params, socket) do
    IO.inspect(job_params, label: "our job params")
    changeset = Jobs.change_with_all_children(socket.assigns.job, job_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"job" => job_params}, socket) do
    save_job(socket, socket.assigns.live_action, job_params)
  end

  defp pop_accomplishment(%{"sub_accomp_sort" => list} = full) do
    [index, accomp] =
      list
      |> List.first()
      |> String.split("-")

    {accomp, %{full | "sub_accomp_sort" => index}}
  end

  defp save_job(socket, :edit, job_params) do
    case Jobs.update_job(socket.assigns.job, job_params) do
      {:ok, job} ->
        {:noreply,
         socket
         |> put_flash(:info, "Job updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, job)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_job(socket, :new, job_params) do
    case Jobs.create_job(socket.assigns.current_scope, job_params) do
      {:ok, job} ->
        {:noreply,
         socket
         |> put_flash(:info, "Job created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, job)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _job), do: ~p"/jobs"
  defp return_path(_scope, "show", job), do: ~p"/jobs/#{job}"
end
