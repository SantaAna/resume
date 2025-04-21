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
    <div :if={@live_action == :list} class="mx-auto max-w-4xl mt-6">
      <.post_list posts={Resume.Posts.posts()} />
    </div>
    <div :if={@live_action == :show} class="mx-auto max-w-4xl">
      {raw(@post.body)}
    </div>
    """
  end
end
