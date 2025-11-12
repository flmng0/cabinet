defmodule CabinetWeb.AdminLive.Clients.Index do
  use CabinetWeb, :live_view

  alias Cabinet.Invoices

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :clients, Invoices.list_clients(socket.assigns.current_scope))}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action)}
  end

  defp apply_action(socket, :index) do
    assign(socket, :page_title, "Clients")
  end

  defp apply_action(socket, :new) do
    assign(socket, :page_title, "Create Client")
  end

  @impl true
  def handle_info({:create_client, attrs}, socket) do
    with {:ok, client} <- Invoices.create_client(socket.assigns.current_scope, attrs) do
      socket =
        socket
        |> stream_insert(:clients, client)
        |> push_patch(to: ~p"/admin/clients")

      {:noreply, socket}
    else
      _ -> {:noreply, socket}
    end
  end
end
