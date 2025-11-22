defmodule Cabinet.Schema.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Cabinet.Schema.Unit
  alias Cabinet.Schema.Client

  schema "invoices" do
    field :term, :string
    field :due, :date

    field :gst, :boolean

    field :late?, :boolean, virtual: true
    field :days_overdue, :integer, virtual: true

    field :subtotal, :decimal, virtual: true
    field :total_gst, :decimal, virtual: true
    field :amount_due, :decimal, virtual: true

    has_many :units, Unit, on_replace: :delete
    belongs_to :client, Client

    timestamps()
  end

  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [:term, :due])
    |> validate_required([:due])
    |> cast_assoc(:units, sort_param: :unit_sort, drop_param: :unit_drop)
  end

  def view_changeset(invoice) do
    change(invoice, viewed: true)
  end

  def with_virtual_fields(query \\ __MODULE__) do
    inner_query = from invoice in __MODULE__, 
      join: unit in assoc(invoice, :units), 
      select: %{ 
        invoice_id: invoice.id, 
        subtotal: sum(unit.count * unit.cost),
        gst_percent: fragment("CASE ? WHEN TRUE THEN 0.1 ELSE 0.0 END", invoice.gst) 
      }, 
      group_by: invoice.id

    
    today = Date.utc_today()

    query = from invoice in query,
      join: totals in subquery(inner_query),
      on: totals.invoice_id == invoice.id,
      select_merge: %{
        subtotal: totals.subtotal,
        total_gst: totals.subtotal * totals.gst_percent,
        amount_due: totals.subtotal * (1 + totals.gst_percent),
        late?: ^today > invoice.due,
        days_overdue: ^today - invoice.due
      }
  end

  def query(opts), do: query(__MODULE__, opts)
  def query(query, opts) do
    if Keyword.get(opts, :full?, false) do
      from invoice in with_virtual_fields(query), preload: [:units, :client]
    else
      query
    end
  end
end
