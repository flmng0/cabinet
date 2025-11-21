defmodule CabinetWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use CabinetWeb, :html

  embed_templates "page_html/*"

  attr :new, :integer
  attr :overdue, :integer
  attr :total, :integer

  def invoice_summary(assigns) do
    assigns =
      assign_new(assigns, :parts, fn %{total: total, new: new, overdue: overdue} ->
        parts = ["You have #{total} #{pluralize(total, "invoice", "invoices")}"]

        parts = if new > 0, do: parts ++ ["#{new} you have not viewed"], else: parts
        parts = if overdue > 0, do: parts ++ ["#{overdue} of which are overdue"], else: parts

        parts
      end)

    ~H"""
    <p>
      {listify(@parts)}.
    </p>
    """
  end
end
