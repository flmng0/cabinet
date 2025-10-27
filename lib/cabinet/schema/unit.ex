defmodule Cabinet.Schema.Unit do
  use Ecto.Schema

  alias Cabinet.Schema.Invoice

  schema "units" do
    field :description, :string
    field :cost, :decimal
    field :count, :integer

    belongs_to :invoice, Invoice
  end
end
