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

superuser_email = Application.compile_env!(:cabinet, :superuser_email)

if nil = Auth.get_user_by_email(superuser_email) do
  {:ok, superuser} = Auth.create_superuser(superuser_email)
end
