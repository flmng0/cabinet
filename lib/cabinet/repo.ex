defmodule Cabinet.Repo do
  use Ecto.Repo,
    otp_app: :cabinet,
    adapter: Ecto.Adapters.Postgres
end
