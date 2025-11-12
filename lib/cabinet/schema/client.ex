defmodule Cabinet.Schema.Client do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cabinet.Auth.User
  alias Cabinet.Schema.Invoice

  schema "clients" do
    field :name, :string
    field :shortcode, :string

    field :address, {:array, :string}, default: []

    has_many :users, User
    has_many :invoices, Invoice

    timestamps()
  end

  def create_changeset(client, attrs) do
    client
    |> cast(attrs, [:name, :shortcode, :address])
    |> validate_required([:name, :shortcode])
    |> validate_format(:shortcode, ~r/^\S+$/, message: "cannot include spaces")
    |> cast_assoc(:users, with: &User.email_changeset/2)
  end
end
