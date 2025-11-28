defmodule CabinetWeb.AdminLive.Invoice.Show do
  use CabinetWeb, :live_view

  alias Cabinet.Invoices

  @impl true
  def mount(_params, _session, socket) do
    clients = Invoices.list_clients(socket.assigns.current_scope)

    {:ok, assign(socket, :clients, clients)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    invoice = Invoices.get_invoice(socket.assigns.current_scope, id, full?: true)
    refnum = CabinetWeb.Util.format_refnum(id)

    title =
      case socket.assigns.live_action do
        :view -> refnum
        :edit -> "Editing " <> refnum
      end

    socket =
      socket
      |> assign(:invoice, invoice)
      |> assign(:access_link, nil)
      |> assign(:page_title, title)

    {:noreply, socket}
  end

  @impl true
  def handle_event("refresh-link", _params, socket) do
    invoice = socket.assigns.invoice
    token = Cabinet.AccessToken.sign(invoice)

    link = url(socket, ~p"/invoice/#{invoice.id}?#{[token: token]}")

    {:noreply, assign(socket, :access_link, link)}
  end

  @impl true
  def handle_info({:submit_invoice, attrs}, socket) do
    with {:ok, invoice} <-
           Invoices.update_invoice(socket.assigns.current_scope, socket.assigns.invoice, attrs) do
      {:noreply, push_patch(socket, to: ~p"/admin/invoice/#{invoice.id}")}
    else
      _ ->
        {:noreply, socket}
    end
  end
end
