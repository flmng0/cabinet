# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Cabinet.Repo.insert!(%Cabinet.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Cabinet.Auth
alias Cabinet.Schema
alias Cabinet.Repo

superuser_email = Application.fetch_env!(:cabinet, :superuser_email)

superuser =
  if is_nil(Auth.get_user_by_email(superuser_email)) do
    Auth.create_superuser!(superuser_email)
  end

client =
  %Schema.Client{
    name: "The List<>",
    shortcode: "the-list"
  }
  |> Repo.insert!()

invoice =
  Ecto.build_assoc(client, :invoices, %{
    title: "Holiday Program Teaching Assistance",
    due: Date.shift(Date.utc_today(), day: 3)
  })
  |> Repo.insert!()

units =
  [
    %{description: "Week 1 - Teaching Hours", count: Decimal.new(14), cost: Decimal.new(40)},
    %{description: "Week 2 - Teaching Hours", count: Decimal.new(12), cost: Decimal.new(40)}
  ]

for unit <- units do
  Ecto.build_assoc(invoice, :units, unit)
  |> Repo.insert!()
end

