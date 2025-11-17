defmodule CabinetWeb.AdminLive.Invoice.Show do
  use CabinetWeb, :live_view

  alias Cabinet.Invoices

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin
      current_scope={@current_scope}
      current_view={:invoice}
    >
      <.header>
        {format_refnum(@invoice.id)}

        <:actions>
          <.button
            :if={@live_action != :edit}
            variant="primary"
            patch={~p"/admin/invoice/#{@invoice.id}/edit"}
            replace
          >
            Edit
          </.button>
        </:actions>
      </.header>

      <.live_component
        :if={@live_action == :edit}
        id="invoice-form"
        module={CabinetWeb.AdminLive.Invoice.FormComponent}
        invoice={@invoice}
        cancel={JS.patch(~p"/admin/invoice/#{@invoice.id}", replace: true)}
      />
    </Layouts.admin>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    clients = Invoices.list_clients(socket.assigns.current_scope)

    {:ok, assign(socket, :clients, clients)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    invoice = Invoices.get_invoice(socket.assigns.current_scope, id)
    refnum = CabinetWeb.Util.format_refnum(id)

    title =
      case socket.assigns.live_action do
        :view -> refnum
        :edit -> "Editing " <> refnum
      end

    socket =
      socket
      |> assign(:invoice, invoice)
      |> assign(:client_id, nil)
      |> assign(:page_title, title)

    {:noreply, socket}
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
