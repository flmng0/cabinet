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

      <Layouts.app>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :current_scope, :map, default: nil
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="h-full flex flex-col">
      <.app_header
        current_scope={@current_scope}
        show_admin={!assigns[:admin_view]}
        class="flex-none print:hidden"
      />

      <.main_container class={[@class, "print:m-0 print:p-0"]}>
        {render_slot(@inner_block)}
      </.main_container>
    </div>
    """
  end

  attr :class, :any, default: nil
  slot :inner_block, required: true

  def main_container(assigns) do
    ~H"""
    <main class={["px-4 py-20 sm:px-6 lg:px-8 grow", @class]}>
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>
    """
  end

  attr :current_scope, :map, default: nil
  attr :contact_name, :string, required: true

  slot :inner_block, required: true
  slot :cta

  def home(assigns) do
    ~H"""
    <div class="h-full flex flex-col">
      <.app_header current_scope={@current_scope} soft />

      <div class="hero grow">
        <div class="hero-content">
          <div class="max-w-lg space-y-6">
            <.header size="hero">
              Cabinet Invoicing
              <:subtitle>Self-hosted invoices for {@contact_name}.</:subtitle>
            </.header>

            {render_slot(@inner_block)}

            <div class="flex justify-center mt-10">
              <%= for cta <- @cta do %>
                {render_slot(cta)}
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :current_view, :atom, required: true, values: ~w(client invoice)a
  attr :current_scope, :map, default: nil

  slot :inner_block, required: true

  slot :util, doc: "action rendered when config setting :dev_utils is enabled" do
    attr :click, :any
  end

  def admin(assigns) do
    assigns =
      assigns
      |> assign(:routes, CabinetWeb.AdminLive.Routes.routes())
      |> assign_new(:current_view, fn -> nil end)

    ~H"""
    <div class="drawer lg:drawer-open lg:bg-base-content">
      <input type="checkbox" id="admin_drawer" class="drawer-toggle" />
      <div class="drawer-content bg-base-100 lg:rounded-md lg:m-1">
        <label
          class="sticky top-0 left-0 m-4 btn btn-soft btn-square btn-neutral drawer-button lg:hidden justify-self-start"
          for="admin_drawer"
          aria-label="Open navigation"
        >
          <.icon name="hero-bars-3" />
        </label>

        <div class="py-10 px-4 w-full max-w-2xl mx-auto">
          {render_slot(@inner_block)}

          <div
            :if={Application.get_env(:cabinet, :dev_utils) && @util != []}
            class="rounded-md border border-secondary-content bg-secondary text-secondary-content p-4 mt-12 col-span-full self-start"
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
        </div>
      </div>

      <nav class="drawer-side">
        <label for="admin_drawer" class="drawer-overlay" />

        <div class="flex flex-col h-screen overflow-y-auto w-72 max-w-screen shadow-md bg-base-content text-base-100">
          <hgroup class="py-8 px-4">
            <h1 class="text-lg lg:text-xl">Cabinet Admin Panel</h1>
            <p class="text-sm lg:text-base">Logged in as {@current_scope.user.email}</p>
          </hgroup>

          <ul class="menu lg:menu-lg w-full gap-1 grow">
            <li :for={{key, route} <- @routes}>
              <.link
                navigate={route.path}
                class={if @current_view == key, do: "menu-active", else: "hover:bg-neutral/50"}
              >
                <.icon name={route.icon} />
                {route.title}
              </.link>
            </li>
          </ul>

          <.link class="btn btn-neutral text-base-100 btn-outline mx-2 my-4" href="/">
            <.icon name="hero-home" /> Return Home
          </.link>
        </div>
      </nav>
    </div>
    """
  end

  @doc """
  App header, including conditional user settings / log-out button.
  """
  attr :current_scope, :map, default: nil
  attr :class, :string, default: nil
  attr :soft, :boolean, default: false

  attr :show_admin, :boolean, default: true

  def app_header(assigns) do
    ~H"""
    <header class={[
      "navbar justify-between px-4 sm:px-6 lg:px-8 gap-4",
      if(@soft, do: "", else: "bg-base-content text-base-100"),
      @class
    ]}>
      <div>
        <.button variant="ghost" href={~p"/"}>Home</.button>

        <div
          :if={@show_admin && Cabinet.Auth.Guards.is_superuser?(@current_scope)}
          class="dropdown dropdown-hover group"
        >
          <div tabindex="0" role="button" class="btn btn-ghost">
            Admin <.icon name="hero-chevron-down" class="size-3" />
          </div>
          <ul
            tabindex="-1"
            class="menu dropdown-content bg-base-100 text-base-content z-1 w-52 p-2 shadow-sm rounded-box"
          >
            <li :for={{key, route} <- CabinetWeb.AdminLive.Routes.routes()}>
              <.link navigate={route.path}>
                <.icon name={route.icon} />
                {route.title}
              </.link>
            </li>
          </ul>
        </div>
      </div>

      <%= if @current_scope do %>
        <details class="dropdown dropdown-end" phx-click-away={JS.remove_attribute("open")}>
          <summary class="btn btn-ghost btn-square">
            <.icon name="hero-user-solid" />
          </summary>

          <ul class="dropdown-content menu bg-base-200 rounded-box shadow-sm text-black">
            <li class="menu-title">
              {@current_scope.user.email}
            </li>
            <li><.link href={~p"/users/settings"}>Settings</.link></li>
            <li><.link href={~p"/users/log-out"} method="delete">Log out</.link></li>
          </ul>
        </details>
      <% else %>
        <ul class="menu menu-horizontal">
          <.link href={~p"/users/log-in"}>Log in</.link>
        </ul>
      <% end %>
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
