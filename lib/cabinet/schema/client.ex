defmodule Cabinet.Schema.Client do
  use Ecto.Schema

  alias Cabinet.Schema.Invoice

  schema "clients" do
    field :name, :string

    has_many :invoices, Invoice

    timestamps()
  end
end
