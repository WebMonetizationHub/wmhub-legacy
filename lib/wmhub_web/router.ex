defmodule WmhubWeb.Router do
  use WmhubWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {WmhubWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :js do
    plug :put_js_content_type
  end

  defp put_js_content_type(conn, _params) do
    Plug.Conn.put_resp_content_type(conn, "text/javascript")
  end

  scope "/", WmhubWeb do
    pipe_through :browser

    get "/", PageController, :index
    
    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Index, :new
    live "/users/:id/edit", UserLive.Index, :edit

    live "/users/:id", UserLive.Show, :show
    live "/users/:id/show/edit", UserLive.Show, :edit
  end

  scope "/", WmhubWeb do
    pipe_through :js

    get "/:token/wmhub.js", ClientRendererController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", WmhubWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: WmhubWeb.Telemetry
    end
  end
end
