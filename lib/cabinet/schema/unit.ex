defmodule Cabinet.Schema.Unit do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cabinet.Schema.Invoice

  schema "units" do
    field :description, :string
    field :cost, :decimal
    field :count, :decimal

    belongs_to :invoice, Invoice
  end

  def changeset(unit, attrs) do
    unit
    |> cast(attrs, [:description, :cost, :count])
    |> validate_required([:description, :cost, :count])
    |> validate_number(:count, greater_than: 1)
  end
end
