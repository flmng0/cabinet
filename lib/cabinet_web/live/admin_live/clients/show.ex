defmodule CabinetWeb.AdminLive.Clients.Show do
  use CabinetWeb, :live_view

  alias Cabinet.Invoices

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    client = Invoices.get_client(socket.assigns.current_scope, id)

    socket =
      socket
      |> assign(:client, client)
      |> assign(:page_title, client.name <> " - Clients")

    {:noreply, socket}
  end
end
