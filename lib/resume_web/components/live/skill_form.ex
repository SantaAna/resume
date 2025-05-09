defmodule ResumeWeb.ComponentsLive.SkillForm do
  @moduledoc """
  Live component for adding and managing existing skills.

  ## Attributes
  - current_scope: requires the default scope.
  """

  use ResumeWeb, :live_component
  alias Resume.Skills

  def update(assigns, socket) do
    skills = Skills.list_skills(assigns.current_scope)

    socket
    |> assign(current_scope: assigns.current_scope)
    |> stream(:skills, skills)
    |> fresh_socket()
    |> then(&{:ok, &1})
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} class="mb-4" phx-change="validate" phx-submit="save" phx-target={@myself}>
        <.input field={@form[:name]} type="text" label="Skill Name" />
        <.input field={@form[:description]} type="text" label="Brief Skill Description" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Skill</.button>
        </footer>
      </.form>
      <.skill_table
        skills={@streams.skills}
        delete_action="skill-deleted"
        edit_action="skill-edit"
        disable_edit={@action == :edit}
        target={@myself}
      />
    </div>
    """
  end

  def handle_event("validate", %{"skill" => skill_params}, socket) do
    cs = Skills.change_skill(socket.assigns.current_scope, socket.assigns.skill, skill_params)
    {:noreply, assign(socket, form: to_form(cs))}
  end

  def handle_event("save", %{"skill" => skill_params}, socket) do
    handle_skill(socket, socket.assigns.action, skill_params)
  end

  def handle_event("skill-deleted", %{"skillid" => id}, socket) do
    skill = Skills.get_skill!(socket.assigns.current_scope, id)
    {:ok, _} = Skills.delete_skill(socket.assigns.current_scope, skill)

    socket
    |> stream_delete(:skills, skill)
    |> then(&{:noreply, &1})
  end

  def handle_event("skill-edit", %{"skillid" => id}, socket) do
    skill = Skills.get_skill!(socket.assigns.current_scope, id)

    socket
    |> stream_delete(:skills, skill)
    |> assign(:form, to_form(Skills.change_skill(socket.assigns.current_scope, skill)))
    |> assign(:skill, skill)
    |> assign(:action, :edit)
    |> then(&{:noreply, &1})
  end

  defp handle_skill(socket, :edit, params) do
    case Skills.update_skill(socket.assigns.current_scope, socket.assigns.skill, params) do
      {:ok, skill} ->
        {:noreply, socket |> stream_insert(:skills, skill) |> fresh_socket()}

      {:error, cs} ->
        {:noreply, assign(socket, form: to_form(cs))}
    end
  end

  defp handle_skill(socket, :new, params) do
    case Skills.create_skill(socket.assigns.current_scope, params) do
      {:ok, skill} ->
        {:noreply, socket |> stream_insert(:skills, skill) |> fresh_socket()}

      {:error, cs} ->
        {:noreply, assign(socket, form: to_form(cs))}
    end
  end

  # preps socket with blank skill and form, and action set to new.
  defp fresh_socket(socket) do
    socket
    |> assign(
      skill: %Skills.Skill{},
      form: to_form(Skills.change_skill(socket.assigns.current_scope, %Skills.Skill{})),
      action: :new
    )
  end
end
