defmodule Cabinet.Repo.Migrations.Invoices do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :name, :string, null: false
      add :shortcode, :string, null: false

      add :address, :string

      timestamps()
    end

    create table(:invoices) do
      add :title, :string
      add :term, :string
      add :due, :date
      add :gst, :boolean
      add :viewed, :boolean, default: false

      add :client_id, references(:clients)

      timestamps()
    end

    create table(:units) do
      add :description, :string, null: false
      add :cost, :decimal, null: false
      add :count, :decimal, null: false

      add :invoice_id, references(:invoices), null: false
    end
  end
end
