defmodule ResumeWeb.Router do
  use ResumeWeb, :router

  import ResumeWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ResumeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :throttle_login do
    plug ResumeWeb.ThrottleLogin
  end

  scope "/", ResumeWeb do
    pipe_through :browser

    live_session :visitor do
      live "/", Live.HomeLive, :home
      live "/resume", Live.ResumeLive, :resume
      live "/posts", Live.PostsLive, :list
      live "/posts/:id", Live.PostsLive, :show
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ResumeWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:resume, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ResumeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ResumeWeb do
    pipe_through [:browser, :owner_only]

    live_session :require_authenticated_user,
      on_mount: [{ResumeWeb.UserAuth, :owner_only}] do
      live "/secret", Live.SecretLive
    end

    # post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", ResumeWeb do
    pipe_through [:browser, :throttle_login]

    live_session :current_user,
      on_mount: [{ResumeWeb.UserAuth, :mount_current_scope}] do
      # live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      # live "/users/log-in/:token", UserLive.Confirmation, :new
      live "/jobs", JobLive.Index
      live "/jobs/new", JobLive.Form, :new
      live "/jobs/:id", JobLive.Show
      live "/jobs/:id/edit", JobLive.Form, :edit
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
