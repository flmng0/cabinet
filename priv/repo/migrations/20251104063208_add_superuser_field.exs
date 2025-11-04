defmodule Cabinet.Repo.Migrations.AddSuperuserField do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :superuser, :boolean, null: false, default: false
    end
  end
end
