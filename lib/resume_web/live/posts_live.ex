defmodule ResumeWeb.Live.PostsLive do
  use ResumeWeb, :live_view

  def handle_params(%{"id" => id}, _uri, socket) do
    socket
    |> assign(id: id)
    |> assign(post: Resume.Posts.get_by_id(id))
    |> then(&{:noreply, &1})
  end

  def handle_params(_, _uri, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div :if={@live_action == :list} class="mx-auto lg:max-w-3xl md:max-w-2xl sm:max-w-xl  mt-6">
      <.post_list posts={Resume.Posts.posts()} />
    </div>
    <div :if={@live_action == :show} class="mx-auto lg:max-w-3xl md:max-w-2xl sm:max-w-xl">
      <h1 class="text-4xl font-bold mb-2 mt-4">{@post.title}</h1>
      {raw(@post.body)}
    </div>
    """
  end
end
