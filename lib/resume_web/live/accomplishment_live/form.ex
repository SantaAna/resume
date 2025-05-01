defmodule ResumeWeb.AccomplishmentLive.Form do
  use ResumeWeb, :live_view

  alias Resume.Accomplishments
  alias Resume.Accomplishments.Accomplishment

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage accomplishment records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="accomplishment-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Accomplishment</.button>
          <.button navigate={return_path(@current_scope, @return_to, @accomplishment)}>
            Cancel
          </.button>
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
    accomplishment = Accomplishments.get_accomplishment!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Accomplishment")
    |> assign(:accomplishment, accomplishment)
    |> assign(
      :form,
      to_form(Accomplishments.change_accomplishment(socket.assigns.current_scope, accomplishment))
    )
  end

  defp apply_action(socket, :new, _params) do
    accomplishment = %Accomplishment{}

    socket
    |> assign(:page_title, "New Accomplishment")
    |> assign(:accomplishment, accomplishment)
    |> assign(
      :form,
      to_form(Accomplishments.change_accomplishment(socket.assigns.current_scope, accomplishment))
    )
  end

  @impl true
  def handle_event("validate", %{"accomplishment" => accomplishment_params}, socket) do
    changeset =
      Accomplishments.change_accomplishment(
        socket.assigns.current_scope,
        socket.assigns.accomplishment,
        accomplishment_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"accomplishment" => accomplishment_params}, socket) do
    save_accomplishment(socket, socket.assigns.live_action, accomplishment_params)
  end

  defp save_accomplishment(socket, :edit, accomplishment_params) do
    case Accomplishments.update_accomplishment(
           socket.assigns.current_scope,
           socket.assigns.accomplishment,
           accomplishment_params
         ) do
      {:ok, accomplishment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Accomplishment updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, accomplishment)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_accomplishment(socket, :new, accomplishment_params) do
    case Accomplishments.create_accomplishment(
           socket.assigns.current_scope,
           accomplishment_params
         ) do
      {:ok, accomplishment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Accomplishment created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, accomplishment)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _accomplishment), do: ~p"/accomplishments"
  defp return_path(_scope, "show", accomplishment), do: ~p"/accomplishments/#{accomplishment}"
end
