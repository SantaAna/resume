defmodule ResumeWeb.ComponentsLive.EducationForm do
  @moduledoc """
  Live component for adding and managing existing educations.

  ## Attributes
  - current_scope: requires the default scope.
  """

  use ResumeWeb, :live_component
  alias Resume.Educations

  def update(assigns, socket) do
    educations = Educations.list_educations(assigns.current_scope)

    socket
    |> assign(current_scope: assigns.current_scope)
    |> stream(:educations, educations)
    |> fresh_socket()
    |> then(&{:ok, &1})
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} class="mb-4" phx-change="validate" phx-submit="save" phx-target={@myself}>
        <.input field={@form[:institution]} type="text" label="Institution Name" />
        <.input field={@form[:institution_type]} type="text" label="Type of Institution" />
        <.input
          field={@form[:diploma_earned]}
          type="text"
          label="Diploma Type e.g. bachelors, masters"
        />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Education</.button>
        </footer>
      </.form>
      <.education_table
        educations={@streams.educations}
        delete_action="education-deleted"
        edit_action="education-edit"
        disable_edit={@action == :edit}
        target={@myself}
      />
    </div>
    """
  end

  def handle_event("validate", %{"education" => edu_params}, socket) do
    cs =
      Educations.change_education(
        socket.assigns.current_scope,
        socket.assigns.education,
        edu_params
      )

    {:noreply, assign(socket, form: to_form(cs))}
  end

  def handle_event("save", %{"education" => edu_params}, socket) do
    handle_edu(socket, socket.assigns.action, edu_params)
  end

  def handle_event("education-deleted", %{"educationid" => id}, socket) do
    edu = Educations.get_education!(socket.assigns.current_scope, id)
    {:ok, _} = Educations.delete_education(socket.assigns.current_scope, edu)

    socket
    |> stream_delete(:educations, edu)
    |> then(&{:noreply, &1})
  end

  def handle_event("education-edit", %{"educationid" => id}, socket) do
    edu = Educations.get_education!(socket.assigns.current_scope, id)

    socket
    |> stream_delete(:educations, edu)
    |> assign(
      :form,
      to_form(Educations.change_education(socket.assigns.current_scope, edu))
    )
    |> assign(:education, edu)
    |> assign(:action, :edit)
    |> then(&{:noreply, &1})
  end

  defp handle_edu(socket, :edit, params) do
    case Educations.update_education(
           socket.assigns.current_scope,
           socket.assigns.education,
           params
         ) do
      {:ok, edu} ->
        {:noreply, socket |> stream_insert(:educations, edu) |> fresh_socket()}

      {:error, cs} ->
        {:noreply, assign(socket, form: to_form(cs))}
    end
  end

  defp handle_edu(socket, :new, params) do
    IO.inspect(params, label: "inserting with params")

    case dbg(Educations.create_education(socket.assigns.current_scope, params)) do
      {:ok, edu} ->
        {:noreply, socket |> stream_insert(:educations, edu) |> fresh_socket()}

      {:error, cs} ->
        {:noreply, assign(socket, form: to_form(cs))}
    end
  end

  # preps socket with blank education and form, and action set to new.
  defp fresh_socket(socket) do
    socket
    |> assign(
      education: %Educations.Education{},
      form:
        to_form(
          Educations.change_education(
            socket.assigns.current_scope,
            %Educations.Education{}
          )
        ),
      action: :new
    )
  end
end
