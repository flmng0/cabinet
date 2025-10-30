defmodule Cabinet.Invoices do
  @moduledoc """
  Context encapsulating methods for invoices.
  """

  alias Cabinet.Repo
  import Ecto.Query, only: [from: 2]

  alias Cabinet.Schema

  def with_virtual_fields(nil), do: nil

  def with_virtual_fields(%Schema.Invoice{} = invoice) do
    due_diff = Date.diff(Date.utc_today(), invoice.due)
    late? = due_diff > 0

    subtotal =
      Enum.reduce(invoice.units, 0, fn %Schema.Unit{} = unit, acc ->
        unit.cost
        |> Decimal.mult(unit.count)
        |> Decimal.add(acc)
      end)

    total_gst =
      if invoice.gst do
        Decimal.mult(subtotal, Decimal.new(1, 10, -2)) |> Decimal.round(2)
      else
        Decimal.new("0.00")
      end

    amount_due = Decimal.add(subtotal, total_gst) |> Decimal.round(2)

    %{
      invoice
      | late?: late?,
        days_overdue: due_diff,
        subtotal: subtotal,
        total_gst: total_gst,
        amount_due: amount_due
    }
  end

  def get_invoice(client, refnum) do
    query =
      from e in Schema.Invoice,
        join: c in assoc(e, :client),
        on: e.client_id == c.id,
        where: c.shortcode == ^client and e.refnum == ^refnum,
        preload: [:units, client: c]

    query
    |> Repo.one()
    |> with_virtual_fields()
  end
end
