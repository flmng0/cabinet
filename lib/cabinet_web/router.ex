defmodule CabinetWeb.Router do
  use CabinetWeb, :router

  import CabinetWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CabinetWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CabinetWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/", InvoiceController, :index
    get "/invoice/:client/:refnum", InvoiceController, :view
  end

  scope "/admin", CabinetWeb do
    pipe_through [:browser, :require_superuser]

    live_session :admin,
      on_mount: [{CabinetWeb.UserAuth, :require_authenticated}] do
      scope "/client", AdminLive.Client do
        live "/", Index, :index
        live "/new", Index, :new

        live "/:id", Show, :view
        live "/:id/edit", Show, :edit
      end

      scope "/invoice", AdminLive.Invoice do
        live "/", Index, :index

        live "/:id", Show, :view
        live "/:id/edit", Show, :edit
      end
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", CabinetWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:cabinet, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      get "/mock-invoice", CabinetWeb.InvoiceController, :view_mock
      live_dashboard "/dashboard", metrics: CabinetWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", CabinetWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{CabinetWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end
  end

  scope "/", CabinetWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{CabinetWeb.UserAuth, :mount_current_scope}] do
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
