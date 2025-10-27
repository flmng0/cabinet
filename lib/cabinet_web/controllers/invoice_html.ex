defmodule CabinetWeb.InvoiceHTML do
  @moduledoc """
  This module contains pages rendered by InvoiceController.

  See the `invoice_html` directory for all templates available.
  """
  use CabinetWeb, :html

  attr :href, :string
  attr :value, :string
  attr :icon_name, :string

  def address_item(assigns) do
    ~H"""
    <a href={@href} class="grid grid-cols-subgrid col-span-2 not-italic">
      <.icon name={@icon_name} class="size-4 self-center" />
      <span>{@value}</span>
    </a>
    """
  end

  embed_templates "invoice_html/*"
end
