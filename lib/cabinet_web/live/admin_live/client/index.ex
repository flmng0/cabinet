defmodule CabinetWeb.AdminLive.Client.Index do
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
  def handle_info({:submit_client, attrs}, socket) do
    with {:ok, client} <- Invoices.create_client(socket.assigns.current_scope, attrs) do
      socket =
        socket
        |> stream_insert(:clients, client)
        |> push_navigate(to: ~p"/admin/client/#{client.id}")

      {:noreply, socket}
    else
      _ -> {:noreply, socket}
    end
  end

  if Application.compile_env(:cabinet, :dev_utils) do
    @impl true
    def handle_event("clear-all", _params, socket) do
      Cabinet.Repo.delete_all(Cabinet.Schema.Client)

      {:noreply, stream(socket, :clients, [], reset: true)}
    end
  end
end
