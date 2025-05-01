defmodule ResumeWeb.AccomplishmentLive.Index do
  use ResumeWeb, :live_view

  alias Resume.Accomplishments

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Accomplishments
        <:actions>
          <.button variant="primary" navigate={~p"/accomplishments/new"}>
            <.icon name="hero-plus" /> New Accomplishment
          </.button>
        </:actions>
      </.header>

      <.table
        id="accomplishments"
        rows={@streams.accomplishments}
        row_click={fn {_id, accomplishment} -> JS.navigate(~p"/accomplishments/#{accomplishment}") end}
      >
        <:col :let={{_id, accomplishment}} label="Name">{accomplishment.name}</:col>
        <:col :let={{_id, accomplishment}} label="Description">{accomplishment.description}</:col>
        <:action :let={{_id, accomplishment}}>
          <div class="sr-only">
            <.link navigate={~p"/accomplishments/#{accomplishment}"}>Show</.link>
          </div>
          <.link navigate={~p"/accomplishments/#{accomplishment}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, accomplishment}}>
          <.link
            phx-click={JS.push("delete", value: %{id: accomplishment.id}) |> hide("##{id}")}
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
    Accomplishments.subscribe_accomplishments(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Listing Accomplishments")
     |> stream(:accomplishments, Accomplishments.list_accomplishments(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    accomplishment = Accomplishments.get_accomplishment!(socket.assigns.current_scope, id)
    {:ok, _} = Accomplishments.delete_accomplishment(socket.assigns.current_scope, accomplishment)

    {:noreply, stream_delete(socket, :accomplishments, accomplishment)}
  end

  @impl true
  def handle_info({type, %Resume.Accomplishments.Accomplishment{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :accomplishments, Accomplishments.list_accomplishments(socket.assigns.current_scope), reset: true)}
  end
end
