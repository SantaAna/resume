defmodule ResumeWeb.ComponentsLive.CertificationForm do
  @moduledoc """
  Live component for adding and managing existing certifications.

  ## Attributes
  - current_scope: requires the default scope.
  """

  use ResumeWeb, :live_component
  alias Resume.Certifications

  def update(assigns, socket) do
    certifications = Certifications.list_certifications(assigns.current_scope)

    socket
    |> assign(current_scope: assigns.current_scope)
    |> stream(:certifications, certifications)
    |> fresh_socket()
    |> then(&{:ok, &1})
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} class="mb-4" phx-change="validate" phx-submit="save" phx-target={@myself}>
        <.input field={@form[:name]} type="text" label="Cert Name" />
        <.input field={@form[:description]} type="text" label="Brief Cert Description" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Cert</.button>
        </footer>
      </.form>
      <.certification_table
        certifications={@streams.certifications}
        delete_action="certification-deleted"
        edit_action="certification-edit"
        disable_edit={@action == :edit}
        target={@myself}
      />
    </div>
    """
  end

  def handle_event("validate", %{"certification" => cert_params}, socket) do
    cs =
      Certifications.change_certification(
        socket.assigns.current_scope,
        socket.assigns.certification,
        cert_params
      )

    {:noreply, assign(socket, form: to_form(cs))}
  end

  def handle_event("save", %{"certification" => cert_params}, socket) do
    handle_cert(socket, socket.assigns.action, cert_params)
  end

  def handle_event("certification-deleted", %{"certificationid" => id}, socket) do
    cert = Certifications.get_certification!(socket.assigns.current_scope, id)
    {:ok, _} = Certifications.delete_certification(socket.assigns.current_scope, cert)

    socket
    |> stream_delete(:certifications, cert)
    |> then(&{:noreply, &1})
  end

  def handle_event("certification-edit", %{"certificationid" => id}, socket) do
    cert = Certifications.get_certification!(socket.assigns.current_scope, id)

    socket
    |> stream_delete(:certifications, cert)
    |> assign(
      :form,
      to_form(Certifications.change_certification(socket.assigns.current_scope, cert))
    )
    |> assign(:certification, cert)
    |> assign(:action, :edit)
    |> then(&{:noreply, &1})
  end

  defp handle_cert(socket, :edit, params) do
    case Certifications.update_certification(
           socket.assigns.current_scope,
           socket.assigns.certification,
           params
         ) do
      {:ok, cert} ->
        {:noreply, socket |> stream_insert(:certifications, cert) |> fresh_socket()}

      {:error, cs} ->
        {:noreply, assign(socket, form: to_form(cs))}
    end
  end

  defp handle_cert(socket, :new, params) do
    case Certifications.create_certification(socket.assigns.current_scope, params) do
      {:ok, cert} ->
        {:noreply, socket |> stream_insert(:certifications, cert) |> fresh_socket()}

      {:error, cs} ->
        {:noreply, assign(socket, form: to_form(cs))}
    end
  end

  # preps socket with blank certifiation and form, and action set to new.
  defp fresh_socket(socket) do
    socket
    |> assign(
      certification: %Certifications.Certification{},
      form:
        to_form(
          Certifications.change_certification(
            socket.assigns.current_scope,
            %Certifications.Certification{}
          )
        ),
      action: :new
    )
  end
end
