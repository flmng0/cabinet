defmodule CabinetWeb.AdminLive.Routes do
  use CabinetWeb, :verified_routes

  defmodule Route do
    defstruct [:title, :icon, :path]
  end

  def routes,
    do: [
      client: %Route{
        title: "Clients",
        icon: "hero-users",
        path: ~p"/admin/client"
      },
      invoice: %Route{
        title: "Invoices",
        icon: "hero-queue-list",
        path: ~p"/admin/invoice"
      }
    ]

  import Phoenix.LiveView
  import Phoenix.Component

  defp assign_current_route(_params, uri, socket) do
    %URI{path: path} = URI.parse(uri)

    socket = assign(socket, current_path: path, admin_view: true)

    {:cont, socket}
  end

  def on_mount(:default, _params, _session, socket) do
    socket = attach_hook(socket, :assign_current_route, :handle_params, &assign_current_route/3)

    {:cont, socket}
  end
end
