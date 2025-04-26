defmodule ResumeWeb.Live.SecretLive do
  use ResumeWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>This is a secret page!</h1>
    """
  end
end
