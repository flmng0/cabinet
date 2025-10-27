defmodule CabinetWeb.InvoiceHTML do
  @moduledoc """
  This module contains pages rendered by InvoiceController.

  See the `invoice_html` directory for all templates available.
  """
  use CabinetWeb, :html

  embed_templates "invoice_html/*"
end
