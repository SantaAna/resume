defmodule ResumeWeb.AccomplishmentLive.Show do
  use ResumeWeb, :live_view

  alias Resume.Accomplishments

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Accomplishment {@accomplishment.id}
        <:subtitle>This is a accomplishment record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/accomplishments"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/accomplishments/#{@accomplishment}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit accomplishment
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@accomplishment.name}</:item>
        <:item title="Description">{@accomplishment.description}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    Accomplishments.subscribe_accomplishments(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Show Accomplishment")
     |> assign(:accomplishment, Accomplishments.get_accomplishment!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Resume.Accomplishments.Accomplishment{id: id} = accomplishment},
        %{assigns: %{accomplishment: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :accomplishment, accomplishment)}
  end

  def handle_info(
        {:deleted, %Resume.Accomplishments.Accomplishment{id: id}},
        %{assigns: %{accomplishment: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current accomplishment was deleted.")
     |> push_navigate(to: ~p"/accomplishments")}
  end
end
