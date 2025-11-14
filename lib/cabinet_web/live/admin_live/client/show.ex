defmodule CabinetWeb.AdminLive.Client.Show do
  use CabinetWeb, :live_view

  alias Cabinet.Invoices
  alias Cabinet.Schema.Client

  embed_templates "client_*"

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    client = Invoices.get_client(socket.assigns.current_scope, id, full?: true)

    if is_nil(client) do
      raise CabinetWeb.NotFoundError, message: "No such client with ID #{id}"
    end

    title = page_title(client, socket.assigns.live_action) <> " - Clients"

    socket =
      socket
      |> assign(:client, client)
      |> stream(:invoices, client.invoices)
      |> assign(:page_title, title)

    {:noreply, socket}
  end

  @impl true
  def handle_event("add-invoice", _params, socket) do
    with {:ok, invoice} <-
           Invoices.create_invoice(socket.assigns.current_scope, socket.assigns.client) do
      {:noreply, stream_insert(socket, :invoices, invoice)}
    else
      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:submit_client, attrs}, socket) do
    with {:ok, client} <-
           Invoices.update_client(socket.assigns.current_scope, socket.assigns.client, attrs) do
      socket =
        socket
        |> assign(:client, client)
        |> push_patch(to: ~p"/admin/client/#{client.id}")

      {:noreply, socket}
    else
      _ -> {:noreply, socket}
    end
  end

  defp page_title(client, :view), do: client.name
  defp page_title(client, :edit), do: "Editing " <> client.name

  attr :client, Client
  attr :invoices, Phoenix.LiveView.LiveStream
  def client_view(assigns)

  attr :client, Client
  def client_edit(assigns)
end
