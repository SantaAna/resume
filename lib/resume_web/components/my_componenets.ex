defmodule ResumeWeb.MyComponenets do
  use Phoenix.Component
  use Gettext, backend: ResumeWeb.Gettext

  # Questionable to include routes for components
  # but since these are our own components I think 
  # it is justified.
  use Phoenix.VerifiedRoutes,
    endpoint: ResumeWeb.Endpoint,
    router: ResumeWeb.Router,
    statics: ResumeWeb.static_paths()

  alias Phoenix.LiveView.JS

  attr :posts, :list, required: true
  attr :title, :string, default: nil

  def post_list(assigns) do
    ~H"""
    <div>
      <h1 class="text-4xl font-bold mb-4">{if @title, do: @title, else: "Posts"}</h1>
      <div class="flex flex-col">
        <.post_list_entry :for={post <- @posts} post={post} />
      </div>
    </div>
    """
  end

  attr :post, :map, required: true

  def post_list_entry(assigns) do
    ~H"""
    <div class="card bg-base-200 shadow-sm hover:shadow-lg transition-shadow duration-200 mb-4 lg:max-w-3xl lg:min-w-3xl md:max-w-2xl sm:max-w-xl">
      <div class="card-body">
        <div class="flex justify-between items-center gap-4">
          <h2 class="card-title text-primary">
            <.link navigate={~p"/posts/#{@post.id}"}>
              {@post.title}
            </.link>
          </h2>
          <span class="text-sm text-base-content/70">
            {Calendar.strftime(@post.date, "%B %d, %Y")}
          </span>
        </div>
        <p class="text-base-content/80 mt-2 line-clamp-2 text-wrap">
          {@post.summary}
        </p>
      </div>
    </div>
    """
  end
end
