defmodule Cabinet.Schema.Client do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Phoenix.Param, key: :shortcode}

  alias Cabinet.Auth.User
  alias Cabinet.Schema.Invoice

  schema "clients" do
    field :name, :string
    field :shortcode, :string

    field :address, :string

    has_many :users, User
    has_many :invoices, Invoice

    timestamps()
  end

  def changeset(client, attrs) do
    client
    |> cast(attrs, [:name, :shortcode, :address])
    |> validate_required([:name, :shortcode])
    |> validate_format(:shortcode, ~r/^\S+$/, message: "cannot include spaces")
    |> cast_assoc(:users, sort_param: :user_sort, drop_param: :user_drop, with: &User.email_changeset/2)
  end
end
