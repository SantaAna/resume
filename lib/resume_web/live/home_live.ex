defmodule ResumeWeb.Live.HomeLive do
  use ResumeWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="container mx-auto  px-4">
      <div class="hero min-h-[60vh]  rounded-box my-8">
        <div class="hero-content text-center">
          <div class="max-w-3xl">
            <h1 class="text-5xl font-bold mb-8">Patrick Struthers</h1>
            <p class="text-2xl mb-4">Security Professional</p>
            <p class="text-xl opacity-90 mb-8">
              Bridging the gap between business needs and security solutions with 10 years of experience in information security.
            </p>
            <div class="flex gap-4 justify-center">
              <.link navigate={~p"/resume"} class="btn btn-primary">View Resume</.link>
              <.link navigate={~p"/posts"} class="btn btn-ghost">Read Blog</.link>
            </div>
          </div>
        </div>
      </div>

      <div class="flex justify-center">
        <.post_list posts={Resume.Posts.posts(:recent)} title="Recent Posts" />
      </div>
    </div>
    """
  end
end
