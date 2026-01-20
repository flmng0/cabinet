defmodule Cabinet.Repo.Migrations.AddInvoicePaid do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      add :paid_at, :date, null: true
    end
  end
end
