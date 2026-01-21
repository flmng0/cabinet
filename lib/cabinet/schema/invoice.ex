defmodule Cabinet.Schema.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Cabinet.Schema.Unit
  alias Cabinet.Schema.Client

  defimpl Phoenix.Param, for: __MODULE__ do
    def to_param(invoice) do
      CabinetWeb.Util.format_refnum(invoice.id)
    end
  end

  schema "invoices" do
    field :title, :string

    field :term, :string
    field :due, :date
    field :paid_at, :date

    field :gst, :boolean

    field :viewed, :boolean, default: false

    field :paid?, :boolean, virtual: true
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
    |> cast(attrs, [:term, :due, :paid_at])
    |> validate_required([:due])
    |> cast_assoc(:units, sort_param: :unit_sort, drop_param: :unit_drop)
  end

  def view_changeset(invoice) do
    change(invoice, viewed: true)
  end

  def with_overdue_status(query \\ __MODULE__) do
    today = Date.utc_today()

    from invoice in query,
      select_merge: %{
        paid?: ^today >= invoice.paid_at,
        late?: is_nil(invoice.paid_at) and ^today > invoice.due,
        days_overdue: ^today - invoice.due
      }
  end

  def with_virtual_fields(query \\ __MODULE__) do
    inner_query =
      from invoice in __MODULE__,
        join: unit in assoc(invoice, :units),
        select: %{
          invoice_id: invoice.id,
          subtotal: sum(unit.count * unit.cost),
          gst_percent: fragment("CASE ? WHEN TRUE THEN 0.1 ELSE 0.0 END", invoice.gst)
        },
        group_by: invoice.id

    from invoice in with_overdue_status(query),
      left_join: totals in subquery(inner_query),
      on: totals.invoice_id == invoice.id,
      select_merge: %{
        subtotal: coalesce(totals.subtotal, 0),
        total_gst: coalesce(totals.subtotal * totals.gst_percent, 0),
        amount_due: coalesce(totals.subtotal * (1 + totals.gst_percent), 0)
      }
  end

  def query(opts), do: query(__MODULE__, opts)

  def query(query, opts) do
    cond do
      Keyword.get(opts, :full?, false) ->
        from with_virtual_fields(query), preload: [:units, :client]

      Keyword.get(opts, :with_status?, false) ->
        from with_overdue_status(query), preload: [:client]

      true ->
        query
    end
  end

  def counts_query(query \\ __MODULE__) do
    today = Date.utc_today()

    from invoice in query,
      select: %{
        new: count(invoice.id) |> filter(not invoice.viewed),
        overdue: count(invoice.id) |> filter(^today > invoice.due),
        total: count(invoice.id)
      }
  end
end
