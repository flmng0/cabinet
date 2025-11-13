defmodule Cabinet.Invoices do
  @moduledoc """
  Context encapsulating methods for invoices.
  """

  alias Cabinet.Repo
  import Ecto.Query, only: [from: 2]

  alias Cabinet.Schema
  alias Cabinet.Auth.{Scope, User}

  import Cabinet.Auth.Guards

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

  def list_clients(%Scope{user: user}, preload? \\ false) when is_superuser(user) do
    query =
      if preload? do
        from c in Schema.Client, preload: [:users, :invoices]
      else
        Schema.Client
      end

    Repo.all(query)
  end

  def create_client(%Scope{user: user}, attrs) when is_superuser(user) do
    %Schema.Client{}
    |> Schema.Client.changeset(attrs)
    |> Repo.insert()
  end

  def update_client(%Scope{user: user}, %Schema.Client{} = client, attrs) when is_superuser(user) do
    client
    |> Schema.Client.changeset(attrs)
    |> Repo.update()
  end

  def get_client(%Scope{user: user}, id) when is_superuser(user) do
    Repo.get(Schema.Client, id)
  end

  def get_invoice(%Scope{user: user}, refnum) when is_superuser(user) do
    Repo.get_by(Schema.Invoice, refnum: refnum) |> with_virtual_fields()
  end

  def get_invoice(%Scope{user: user}, refnum) do
    %User{client_id: client_id} = Repo.preload(user, [:client])

    query = from e in Schema.Invoice, where: e.client_id == ^client_id, preload: [:units]

    query
    |> Repo.get_by(refnum: refnum)
    |> with_virtual_fields()
  end
end
