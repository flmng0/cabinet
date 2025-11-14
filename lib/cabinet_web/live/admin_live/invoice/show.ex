defmodule CabinetWeb.AdminLive.Invoice.Show do
  use CabinetWeb, :live_view

  alias Cabinet.Invoices

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_scope={@current_scope}>
      <%= if @invoice do %>
        <.header>
          {format_refnum(@invoice.id)}
        </.header>
      <% end %>

      <.live_component
        id="invoice-form"
        module={CabinetWeb.AdminLive.Invoice.FormComponent}
        client_id={@client_id}
        invoice={@invoice}
        clients={@clients}
        cancel={cancel_action(@client_id)}
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
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, params, socket.assigns.live_action)}
  end

  defp apply_action(socket, params, :new) do
    socket
    |> assign(:invoice, nil)
    # can be nil
    |> assign(:client_id, params["client"])
    |> assign(:page_title, "Create Invoice")
  end

  defp apply_action(socket, %{"id" => id}, action) when action in [:view, :edit] do
    invoice = Invoices.get_invoice(socket.assigns.current_scope, id)
    refnum = CabinetWeb.Util.format_refnum(id)

    title =
      case action do
        :view -> refnum
        :edir -> "Editing " <> refnum
      end

    socket
    |> assign(:invoice, invoice)
    |> assign(:client_id, nil)
    |> assign(:page_title, title)
  end

  defp cancel_action(nil), do: JS.navigate(~p"/admin/invoice")
  defp cancel_action(id), do: JS.navigate(~p"/admin/client/#{id}")
end
