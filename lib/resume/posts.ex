defmodule Resume.Posts.Post do
  defstruct [:id, :title, :body, :tags, :date, :summary]

  def build(_filename, attrs, body) do
    attrs
    |> Map.update!(:date, &Date.from_iso8601!/1)
    |> Map.put(:body, body)
    |> then(&struct!(__MODULE__, &1))
  end
end

defmodule Resume.Posts.PostStyling do
  alias Earmark.AstTools

  def add_classes(class_list) do
    fn node -> AstTools.merge_atts_in_node(node, class: Enum.join(class_list, " ")) end
  end

  def post_registered_processors() do
    [
      {"h1", add_classes(~w(text-3xl))},
      {"h2", add_classes(~w(text-2xl font-bold mb-4 mt-8))},
      {"h3", add_classes(~w(text-xl font-semi-bold mb-4 mt-4))},
      {"ol", add_classes(~w(list-decimal list-inside ml-2 mb-2))},
      {"ul", add_classes(~w(list-disc list-inside ml-2 mb-2))},
      {"li", add_classes(~w(text-base-content))},
      {"hr", add_classes(~w(text-base-content))},
      {"p", add_classes(~w(text-base-content prose leading-7 mb-4))},
      {"a", add_classes(~w(link link-primary))},
      {"img", add_classes(~w(mx-auto my-3))},
      {"blockquote", add_classes(~w(border-l-4 border-accent p-4))},
      {"table", add_classes(~w(w-full border-collapse border-2 border-accent my-2))},
      {"th", add_classes(~w(p-2 border-2 border-accent))},
      {"td", add_classes(~w(p-2 border-2 border-accent))}
    ]
  end
end

defmodule Resume.Posts do
  alias Resume.Posts.{Post, PostStyling}

  use NimblePublisher,
    build: Post,
    from: Application.app_dir(:resume, "priv/posts/*.md"),
    as: :posts,
    highlighters: [:makeup_elixir, :makeup_erlang],
    earmark_options:
      Earmark.Options.make_options!(
        registered_processors: PostStyling.post_registered_processors()
      )

  @doc """
  Returns `count` posts that should be 
  displayed on the front page. The posts will  
  be sorted by date in descending order. 
  """
  def front_page_posts(count),
    do:
      @posts
      |> Enum.filter(&has_tag?(&1, "public"))
      |> Enum.filter(&has_tag?(&1, "frontpage"))
      |> Enum.sort_by(& &1.date, :desc)
      |> Enum.take(count)

  @doc """
  returns all posts.  By default will return sorted by 
  date, but you can provide a custom `sort_field` and 
  `order`.
  """
  def all_posts(sort_field \\ :date, order \\ :desc) do
    @posts
    |> Enum.sort_by(&Map.get(&1, sort_field), order)
  end

  def public_posts(sort_field \\ :date, order \\ :desc) do
    all_posts(sort_field, order)
    |> Enum.filter(&has_tag?(&1, "public"))
  end

  @doc """
  Fetches the post with the given id.
  """
  def by_id(id) when is_binary(id) do
    @posts
    |> Enum.find(&(&1.id == id))
  end

  defp has_tag?(post, tag) do
    tag in post.tags
  end
end
