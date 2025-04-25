defmodule ResumeWeb.UserLive.Login do
  use ResumeWeb, :live_view

  alias Resume.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        <p>Log in</p>
      </.header>

      <.form
        for={@form}
        id="login_form_password"
        action={~p"/users/log-in"}
        phx-submit="submit_password"
        phx-trigger-action={@trigger_submit}
      >
        <.input
          readonly={!!@current_scope}
          field={@form[:email]}
          type="email"
          label="Email"
          autocomplete="username"
          required
        />
        <.input
          field={@form[:password]}
          type="password"
          label="Password"
          autocomplete="current-password"
        />
        <.input
          :if={!@current_scope}
          field={@form[:remember_me]}
          type="checkbox"
          label="Keep me logged in"
        />
        <.button class="w-full" variant="primary">
          Log in <span aria-hidden="true">→</span>
        </.button>
      </.form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end
end
