%{
  title: "making this site",
  date: "2025-04-22",
  id: "2",
  tags: ~w(elixir web public frontpage), 
  summary: "Making a personal site with Phoenix and MarkDown"
}
---

It's important to control the essential parts of your online identity and a good place to start is a personal site.

## Tech Choices

In the spirit of taking control I set out to limit the number of externally hosted dependencies.  I don't want to be hosted a bespoke platform that could increase pricing or monitor traffic.

This site relies on:
- GitHub: for hosting code and docker images.
- Hetzner: for hosting a small Linux VPS.

If either one moved in a direction I'm uncomfortable with I could easily pick up my git repo and move on.

Of course, I'm using a lot of open source tools to build the site, but they can't act as a landlord in the way a platform provider can.  I can't be evicted from Linux or Elixir, and they can't raise my rent or dictate what content is allowed.  I'm also allowed to patch up and renovate as I like - I doubt that I would be allowed to fork a big cloud provider. 

### Elixir + Phoenix

Let's start with honesty: I chose these tools because I like them.  That is the most important criteria for any personal project.

Now if I had to articulate why I like them these would be my top three reasons:
- Immutable data makes reasoning about, reading, and debugging code **much** easier. 
- The tooling around Elixir is stable and comprehensive - there are no VC backed bundlers, builders, or core libraries with their associated hype and fomo.
- Phoneix is a batteries included framework with everything needed to build modern websites.  There are simpler frameworks, but I'd rather have one tool that I can pick up and get to work rather than a pile of specialized tools I have to consider before even getting started.

## Serving Content

The [getting started guide](https://hexdocs.pm/phoenix/up_and_running.html) is where to start, then once we have our project built we will need to create some content to serve.

### Creating Markdown Content

I'm using [nimble publisher](https://github.com/dashbitco/nimble_publisher) to convert my markdown files into HTML.  

The only key element missing from the documentation is how to get custom styling into the generated HTML. I created a module to take care of generating the processors

```elixir
defmodule App.Posts.PostStyling do
  alias Earmark.AstTools

  def add_classes(class_list) do
    #will walk the AST and merge provided class 
    #attributes into a node.
    fn node -> 
      AstTools.merge_atts_in_node(node, 
        class: Enum.join(class_list, " ")
      ) 
    end
  end

  def post_registered_processors() do
    [
      
      {"h1", add_classes(~w(text-2xl))},
      #add other classes here. 
      #Earmark will match against node types.
    ]
  end
end
```
Now you just need to tell nimble publisher to use your processors:  

```elixir
defmodule App.Posts do
  alias App.Posts.{Post, PostStyling}

  use NimblePublisher,
    build: Post,
    from: Application.app_dir(:resume, "priv/posts/*.md"),
    as: :posts,
    highlighters: [:makeup_elixir, :makeup_erlang],
    earmark_options:
      #Earmark is the library that takes care of parsing md files
      Earmark.Options.make_options!(
        #registering our processors will tell earmark to 
        #invoke them on its generated AST.
        registered_processors: PostStyling.post_registered_processors()
      )
end

```
Finally, if you are using tailwind, you will need to tell it where it can find the classes you are using so it doesn't prune them from it's final build.  In tailwind v4 you can do this as an '@source' directive in your app.css

```css
@source "../../path/to/sytling_module.ex";
```

### Routing to Posts 

I'm handling this with [live routes](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.Router.html#live/4).  For now I don't need the functionality of [LiveView](https://hexdocs.pm/phoenix/up_and_running.html), but it's nice to have it available in the future and the added overhead is minor.

```elixir
  scope "/", AppWeb do
    pipe_through :browser

    live_session :visitor do
      live "/", Live.HomeLive, :home
      live "/posts", Live.PostsLive, :list
      live "/posts/:id", Live.PostsLive, :show
    end
  end
```

The route to PostsLive is doing the most work here.  If we provide an id in the posts path it will extract it and pass it to the PostsLive module so it can be rendered.  With or without the id we will pass along a live action value (the `:list` and `:show`) to give added context to the PostsLive module about what it is supposed to render.

```elixir
defmodule AppWeb.Live.PostsLive do
  use AppWeb, :live_view

  #if we get an ID we want to extract it 
  #put it in our socket
  def handle_params(%{"id" => id}, _uri, socket) do
    socket
    |> assign(id: id)
    |> assign(post: App.Posts.get_by_id(id))
    |> then(&{:noreply, &1})
  end

  #if we don't then we can just pass 
  #along the socket.
  def handle_params(_, _uri, socket) do
    {:noreply, socket}
  end

  #rendering our html based on assigns
  #and our live_actions
  def render(assigns) do
    ~H"""
     <!-- 
     we check the live action value and decide what to render
      -->
    <div :if={@live_action == :list} class="mx-auto max-w-4xl mt-6">
     <!-- 
      Posts.posts() returns all visible posts.
      -->
      <.post_list posts={App.Posts.posts()} />
    </div>
    <div :if={@live_action == :show} class="mx-auto max-w-4xl">
      <h1 class="text-3xl font-semi-bold mb-2 mt-4">
         {@post.title}
       </h1>
      {raw(@post.body)}
    </div>
    """
  end
end
```
[handle_params/1](https://hexdocs.pm/phoenix/up_and_running.html) is called whenever the liveview is loaded, so we need to provide a default implementation that will work without an id value.  [render/1](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#c:render/1) is responsible for generating HTML for the client and it decides what to render based on the live action provided by the router.

In general the call to [`raw/1`](https://hexdocs.pm/phoenix_html/Phoenix.HTML.html#raw/1) is not good practice because it doesn't escape HTML, but in this case we will **never** be rendering content from the user.

## Final Thoughts

I'm happy with the setup so far. The one pain point is the app must be recompiled and redeployed whenever an article is added, but deploying with docker compose and git actions smooths the process considerably.

