defmodule CabinetWeb.AdminLive.Invoice.Index do
  use CabinetWeb, :live_view

  import CabinetWeb.AdminLive.Common, only: [invoice_table: 1]

  alias Cabinet.Invoices

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin current_view={:invoice}>
      <.invoice_table
        invoices={@streams.invoices}
        show_client
        row_click={fn {_, i} -> JS.navigate(~p"/admin/invoice/#{i.id}") end}
        new_click="add-invoice"
      />

      <:util click="clear-all">Clear Invoices</:util>
    </Layouts.admin>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    invoices = Invoices.list_invoices(socket.assigns.current_scope, full?: true)

    socket = socket |> assign(:page_title, "Invoices") |> stream(:invoices, invoices)

    {:ok, socket}
  end

  if Application.compile_env(:cabinet, :dev_utils) do
    @impl true
    def handle_event("clear-all", _params, socket) do
      Cabinet.Repo.delete_all(Cabinet.Schema.Invoice)

      {:noreply, stream(socket, :invoices, [], reset: true)}
    end
  end
end
