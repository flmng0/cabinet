defmodule Cabinet.Schema.Invoice do
  use Ecto.Schema

  alias Cabinet.Schema.Unit
  alias Cabinet.Schema.Client

  schema "invoices" do
    field :term, :string
    field :due, :utc_datetime

    has_many :units, Unit
    belongs_to :client, Client

    timestamps()
  end
end
