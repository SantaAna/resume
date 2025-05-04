defmodule ResumeWeb.ComponentsLive.TechnologyForm do
  @moduledoc """
  Live component for adding and managing existing technologies.

  ## Attributes
  - current_scope: requires the default scope.
  """

  use ResumeWeb, :live_component
  alias Resume.Technologies

  def update(assigns, socket) do
    techs = Technologies.list_technologies(assigns.current_scope)

    socket
    |> assign(current_scope: assigns.current_scope)
    |> stream(:technologies, techs)
    |> fresh_socket()
    |> then(&{:ok, &1})
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} class="mb-4" phx-change="validate" phx-submit="save" phx-target={@myself}>
        <.input field={@form[:name]} type="text" label="Tech Name" />
        <.input field={@form[:description]} type="text" label="Brief Tech Description" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Tech</.button>
        </footer>
      </.form>
      <.technology_table
        technologies={@streams.technologies}
        delete_action="technology-deleted"
        edit_action="technology-edit"
        disable_edit={@action == :edit}
        target={@myself}
      />
    </div>
    """
  end

  def handle_event("validate", %{"technology" => tech_params}, socket) do
    cs =
      Technologies.change_technology(
        socket.assigns.current_scope,
        socket.assigns.technology,
        tech_params
      )

    {:noreply, assign(socket, form: to_form(cs))}
  end

  def handle_event("save", %{"technology" => tech_params}, socket) do
    handle_tech(socket, socket.assigns.action, tech_params)
  end

  def handle_event("technology-deleted", %{"technologyid" => id}, socket) do
    tech = Technologies.get_technology!(socket.assigns.current_scope, id)
    {:ok, _} = Technologies.delete_technology(socket.assigns.current_scope, tech)

    socket
    |> stream_delete(:technologies, tech)
    |> then(&{:noreply, &1})
  end

  def handle_event("technology-edit", %{"technologyid" => id}, socket) do
    tech = Technologies.get_technology!(socket.assigns.current_scope, id)

    socket
    |> stream_delete(:technologies, tech)
    |> assign(
      :form,
      to_form(Technologies.change_technology(socket.assigns.current_scope, tech))
    )
    |> assign(:technology, tech)
    |> assign(:action, :edit)
    |> then(&{:noreply, &1})
  end

  defp handle_tech(socket, :edit, params) do
    case Technologies.update_technology(
           socket.assigns.current_scope,
           socket.assigns.technology,
           params
         ) do
      {:ok, tech} ->
        {:noreply, socket |> stream_insert(:technologies, tech) |> fresh_socket()}

      {:error, cs} ->
        {:noreply, assign(socket, form: to_form(cs))}
    end
  end

  defp handle_tech(socket, :new, params) do
    case Technologies.create_technology(socket.assigns.current_scope, params) do
      {:ok, tech} ->
        {:noreply, socket |> stream_insert(:technologies, tech) |> fresh_socket()}

      {:error, cs} ->
        {:noreply, assign(socket, form: to_form(cs))}
    end
  end

  # preps socket with blank technology and form, and action set to new.
  defp fresh_socket(socket) do
    socket
    |> assign(
      technology: %Technologies.Technology{},
      form:
        to_form(
          Technologies.change_technology(socket.assigns.current_scope, %Technologies.Technology{})
        ),
      action: :new
    )
  end
end
