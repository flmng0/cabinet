defmodule Cabinet.Repo.Migrations.Invoices do
  use Ecto.Migration

  def change do
    create table("clients") do
      add :name, :string, null: false
      add :shortcode, :string, null: false

      timestamps()
    end
    
    create table("invoices") do
      add :term, :string, null: false
      add :due, :utc_datetime
      add :gst, :boolean

      add :client_id, references("clients")

      timestamps()
    end

    create table("units") do
      add :description, :string, null: false
      add :cost, :decimal, null: false
      add :count, :integer, null: false

      add :invoice_id, references("invoices")
    end
  end
end
