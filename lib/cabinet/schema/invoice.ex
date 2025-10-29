defmodule Cabinet.Schema.Invoice do
  use Ecto.Schema

  alias Cabinet.Schema.Unit
  alias Cabinet.Schema.Client

  schema "invoices" do
    field :term, :string
    field :due, :utc_datetime

    field :gst, :boolean

    field :refnum, :integer 

    field :late?, :boolean, virtual: true
    field :days_overdue, :integer, virtual: true

    field :subtotal, :decimal, virtual: true
    field :total_gst, :decimal, virtual: true
    field :amount_due, :decimal, virtual: true

    has_many :units, Unit
    belongs_to :client, Client

    timestamps()
  end
end
