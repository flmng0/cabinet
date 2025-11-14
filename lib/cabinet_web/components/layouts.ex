defmodule CabinetWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use CabinetWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  attr :class, :string, default: ""

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="flex flex-col min-h-screen">
      <.app_header current_scope={@current_scope} />

      <main class={["px-4 py-20 sm:px-6 lg:px-8 bg-base-200 grow", @class]}>
        <div class="mx-auto max-w-2xl space-y-4">
          {render_slot(@inner_block)}
        </div>
      </main>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  attr :title, :string, required: true
  attr :icon, :string, default: nil

  attr :rest, :global, include: ~w(flash current_scope class)

  slot :inner_block, required: true

  slot :util, doc: "action rendered when config setting :dev_utils is enabled" do
    attr :click, :any
  end

  slot :crumb, doc: "breadcrumb entries" do
    attr :icon, :string
    attr :path, :string
  end

  def admin(assigns) do
    ~H"""
    <.app {@rest}>
      <nav class="text-sm pb-4">
        <ul class="inline-flex items-center gap-2">
          <li>
            <.icon name="hero-wrench-screwdriver" />
          </li>
          <.icon name="hero-chevron-right" class="size-3 text-base-content/80" />
          <%= for crumb <- @crumb do %>
            <li>
              <.link class="hover:underline cursor-pointer" navigate={crumb.path}>
                <.icon name={crumb.icon} />
                {render_slot(crumb)}
              </.link>
            </li>
            <.icon name="hero-chevron-right" class="size-3 text-base-content/80" />
          <% end %>
          <li>
            <span>
              <.icon :if={@icon} name={@icon} />
              {@title}
            </span>
          </li>
        </ul>
      </nav>

      {render_slot(@inner_block)}

      <div
        :if={Application.fetch_env!(:cabinet, :dev_utils) && @util != []}
        class="rounded-md border border-secondary-content bg-secondary text-secondary-content p-4 mt-12"
      >
        <.header>
          <p>Developer Utilities</p>
          <:subtitle>
            <p>Quick utilities only available in the development environment.</p>
          </:subtitle>
        </.header>

        <ul class="flex flex-row flex-wrap">
          <li :for={item <- @util}>
            <.button phx-click={item[:click]} class="btn btn-soft btn-info">
              {render_slot(item)}
            </.button>
          </li>
        </ul>
      </div>
    </.app>
    """
  end

  @doc """
  App header, including conditional user settings / log-out button.
  """
  attr :current_scope, :map, default: nil

  def app_header(assigns) do
    ~H"""
    <header class="navbar px-4 sm:px-6 lg:px-8 gap-4">
      <.button class="btn btn-ghost" href={~p"/"}>Home</.button>

      <div
        :if={Cabinet.Auth.Guards.is_superuser?(@current_scope)}
        class="dropdown dropdown-hover group"
      >
        <div tabindex="0" role="button" class="btn btn-ghost">
          Admin <.icon name="hero-chevron-down" class="size-3" />
        </div>
        <ul tabindex="-1" class="menu dropdown-content bg-base-100 z-1 w-52 p-2 shadow-sm">
          <li><.link href={~p"/admin/client"}>Clients</.link></li>
          <li><.link href={~p"/admin/invoice"}>Invoices</.link></li>
        </ul>
      </div>

      <ul class="menu menu-horizontal w-full relative z-10 flex items-center gap-4 px-4 sm:px-6 lg:px-8 justify-end">
        <%= if @current_scope do %>
          <li>
            {@current_scope.user.email}
          </li>
          <li>
            <.link href={~p"/users/settings"}>Settings</.link>
          </li>
          <li>
            <.link href={~p"/users/log-out"} method="delete">Log out</.link>
          </li>
        <% else %>
          <li>
            <.link href={~p"/users/log-in"}>Log in</.link>
          </li>
        <% end %>
      </ul>
    </header>
    """
  end

  attr :status, :any
  slot :inner_block, required: true

  def error(assigns)

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite" class="contents">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
