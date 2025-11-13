defmodule CabinetWeb.AdminLive.Clients.Show do
  use CabinetWeb, :live_view

  alias Cabinet.Invoices
  alias Cabinet.Schema.Client

  embed_templates "client_*"

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    client =
      Invoices.get_client(socket.assigns.current_scope, id, full?: true)

    title = page_title(client, socket.assigns.live_action) <> " - Clients"

    socket =
      socket
      |> assign(:client, client)
      |> stream(:invoices, client.invoices)
      |> assign(:page_title, title)

    {:noreply, socket}
  end

  defp page_title(client, :view), do: client.name
  defp page_title(client, :edit), do: "Editing " <> client.name
  defp page_title(client, :new_invoice), do: "New Invoice - " <> client.name

  attr :client, Client
  attr :invoices, Phoenix.LiveView.LiveStream
  def client_view(assigns)

  attr :client, Client
  def client_edit(assigns)

  @impl true
  def handle_info({:submit_client, attrs}, socket) do
    with {:ok, client} <-
           Invoices.update_client(socket.assigns.current_scope, socket.assigns.client, attrs) do
      socket =
        socket
        |> assign(:client, client)
        |> push_patch(to: ~p"/admin/clients/#{client.id}")

      {:noreply, socket}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_info({:submit_invoice, attrs}, socket) do
    IO.inspect(attrs, label: "Invoice created")

    {:noreply, socket}

    # with {:ok, invoice} <- Invoices.create_invoice(socket.assigns.current_scope, socket.assigns.client, attrs) do
    #   {:noreply, push_navigate(socket, to: ~p"/admin/")}
    # end
  end
end
