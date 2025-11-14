defmodule Cabinet.Schema.Invoice do
  use Ecto.Schema
  import Ecto.Changeset

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

    has_many :units, Unit
    belongs_to :client, Client

    timestamps()
  end

  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [:term, :due])
    |> validate_required([:due])
    |> cast_assoc(:client)
  end
end
