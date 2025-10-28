defmodule CabinetWeb.InvoiceHTML do
  @moduledoc """
  This module contains pages rendered by InvoiceController.

  See the `invoice_html` directory for all templates available.
  """
  use CabinetWeb, :html

  alias Cabinet.Schema.Invoice

  attr :invoice, Invoice
  attr :gst?, :boolean

  def calculate_subtotal(%Invoice{} = invoice) do
    for unit <- invoice.units, reduce: Decimal.new(0) do
      acc ->
        unit.cost
        |> Decimal.mult(unit.count)
        |> Decimal.add(acc)
    end
  end

  def invoice_total(assigns) do
    subtotal = calculate_subtotal(assigns.invoice)

    assigns =
      if assigns.gst? do
        total_gst = Decimal.mult(subtotal, Decimal.new(1, 10, -2)) |> Decimal.round(2)
        amount_due = Decimal.add(subtotal, total_gst) |> Decimal.round(2)

        assigns
        |> assign(:subtotal, subtotal)
        |> assign(:total_gst, total_gst)
        |> assign(:amount_due, amount_due)
      else
        assign(assigns, :amount_due, subtotal)
      end

    ~H"""
    <div class="flex justify-end">
      <table class="table w-fit text-base-content/60">
        <tbody>
        <%= if @gst? do %>
          <tr>
            <th span="row">Subtotal</th>
            <td class="text-right">{@subtotal}</td>
          </tr>
          <tr>
            <th span="row">Total GST 10%</th>
            <td class="text-right">{@total_gst}</td>
          </tr>
        <% end %>
        <tr class="bg-base-200 text-base-content">
          <th span="row">Total amount due</th>
          <td class="text-lg text-right">{@amount_due}</td>
        </tr>
        </tbody>
      </table>
    </div>
    """
  end
  
  slot :inner_block, required: true

  def section_label(assigns) do
    ~H"""
    <h2 class="text text-base-content/50 font-mono lowercase">{render_slot(@inner_block)}</h2>
    """
  end

  def late?(%Invoice{due: due}), do: Date.after?(Date.utc_today(), due)

  def late_by(%Invoice{due: due}), do: Date.diff(Date.utc_today(), due)

  embed_templates "invoice_html/*"
end
