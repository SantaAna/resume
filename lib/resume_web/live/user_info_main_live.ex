defmodule ResumeWeb.Live.UserInfoMainLive do
  alias ResumeWeb.ComponentsLive
  use ResumeWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage job records in your database.</:subtitle>
      </.header>

      <.live_component module={ComponentsLive.SkillForm} id={:new} current_scope={@current_scope} />
      <.live_component
        module={ComponentsLive.TechnologyForm}
        id={:new}
        current_scope={@current_scope}
      />
      <.live_component
        module={ComponentsLive.CertificationForm}
        id={:new}
        current_scope={@current_scope}
      />
      <.live_component module={ComponentsLive.EducationForm} id={:new} current_scope={@current_scope} />
      <.live_component module={ComponentsLive.JobForm} id={:new} current_scope={@current_scope} />
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Main Info Page")}
  end
end
