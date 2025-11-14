defmodule CabinetWeb.AdminLive.Invoice.Show do
  use CabinetWeb, :live_view

  alias Cabinet.Invoices
  alias Cabinet.Schema.Invoice

  @impl true
  def handle_params(params, _url, socket) do
    socket =
      socket
      |> apply_action(params, socket.assigns.live_action)
      |> assign_form(%{})

    {:ok, socket}
  end

  defp apply_action(socket, params, :new) do
    socket
    |> assign(:invoice, %Invoice{})
    # can be nil
    |> assign(:client_id, params[:client])
    |> assign(:page_title, "Create Invoice")
  end

  defp apply_action(socket, %{"id" => id}, action) when action in [:view, :edit] do
    # invoice = Invoices.get_invoice(socket.assigns.current_scope, id)
    #
    # title = case action do
    #   :view -> 
    # end
    # socket
    #   |> assign(:invoice, Invoices.get_invoice(socket.assigns.current_scope, id))
    #   |> assign(:page_title, )
    socket
  end

  defp assign_form(socket, params, opts \\ []) do
    form =
      socket.assigns.invoice
      |> Invoice.changeset(params)
      |> to_form(opts)

    assign(socket, :form, form)
  end
end
