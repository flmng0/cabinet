defmodule CabinetWeb.InvoiceHTML do
  @moduledoc """
  This module contains pages rendered by InvoiceController.

  See the `invoice_html` directory for all templates available.
  """
  use CabinetWeb, :html

  alias Cabinet.Schema.Invoice

  embed_templates "invoice_html/*"

  slot :inner_block, required: true

  def section_label(assigns) do
    ~H"""
    <h2 class="text text-base-content/50 font-mono lowercase text-sm">{render_slot(@inner_block)}</h2>
    """
  end

  slot :inner_block, required: true

  def unit_var(assigns) do
    ~H"""
    <var class="not-italic inner-block px-2 py-1 rounded-md border border-base-300 bg-base-100">
      {render_slot(@inner_block)}
    </var>
    """
  end

  attr :invoice, Invoice, required: true

  def due_date(assigns) do
    ~H"""
    <span class={@invoice.late? && "text-error"}>
      <%= if @invoice.late? do %>
        <time>{format_date(@invoice.due)}</time> &mdash; {@invoice.days_overdue} days overdue
      <% else %>
        <time>{format_date(@invoice.due)}</time>
      <% end %>
    </span>
    """
  end
end
