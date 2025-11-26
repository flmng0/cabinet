defmodule Cabinet.Invoices do
  @moduledoc """
  Context encapsulating methods for invoices.
  """

  alias Cabinet.AccessToken
  alias Cabinet.Auth.Scope
  alias Cabinet.Auth.User
  alias Cabinet.Repo
  alias Cabinet.Schema

  import Ecto.Query, only: [from: 2]

  import Cabinet.Auth.Guards

  def list_clients(%Scope{user: user}, opts \\ []) when is_superuser(user) do
    query =
      if Keyword.get(opts, :full?, false) do
        from Schema.Client, preload: [:users, :invoices]
      else
        Schema.Client
      end

    Repo.all(query)
  end

  def get_client(%Scope{user: user}, id, opts \\ []) when is_superuser(user) do
    query =
      if Keyword.get(opts, :full?, false) do
        from Schema.Client, preload: [:users, :invoices]
      else
        Schema.Client
      end

    Repo.get(query, id)
  end

  def create_client(%Scope{user: user}, attrs) when is_superuser(user) do
    %Schema.Client{}
    |> Schema.Client.changeset(attrs)
    |> Repo.insert()
  end

  def update_client(%Scope{user: user}, %Schema.Client{} = client, attrs)
      when is_superuser(user) do
    client
    |> Schema.Client.changeset(attrs)
    |> Repo.update()
  end

  def list_invoices(scope, opts \\ [])

  def list_invoices(%Scope{user: user}, opts) when is_superuser(user) do
    Schema.Invoice.query(opts) |> Repo.all()
  end

  def list_invoices(%Scope{client: client}, opts) do
    query = from invoice in Schema.Invoice, where: invoice.client_id == ^client.id

    Schema.Invoice.query(query, opts) |> Repo.all()
  end

  def get_invoice_counts(%Scope{} = scope) do
    query =
      if is_superuser?(scope.user) do
        Schema.Invoice
      else
        from invoice in Schema.Invoice, where: invoice.client_id == ^scope.client.id
      end

    Schema.Invoice.counts_query(query) |> Repo.one()
  end

  def get_invoice(scope, id, opts \\ [])

  def get_invoice(%Scope{user: user}, id, opts) when is_superuser(user) do
    Schema.Invoice.query(opts) |> Repo.get(id)
  end

  def get_invoice(%Scope{client: client}, id, opts) do
    query = from e in Schema.Invoice, where: e.client_id == ^client.id
    Schema.Invoice.query(query, opts) |> Repo.get(id)
  end

  def get_invoice(%AccessToken{invoice_id: id}, id, opts) do
    Schema.Invoice.query(opts) |> Repo.get(id)
  end

  def get_invoice(_, _id, _opts), do: nil

  def create_invoice(scope, client) do
    create_invoice(scope, client, Date.shift(Date.utc_today(), week: 1))
  end

  def create_invoice(%Scope{user: user}, %Schema.Client{} = client, due)
      when is_superuser(user) do
    client
    |> Ecto.build_assoc(:invoices, due: due)
    |> Repo.insert()
  end

  def update_invoice(%Scope{user: user}, %Schema.Invoice{} = invoice, attrs)
      when is_superuser(user) do
    invoice
    |> Schema.Invoice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Mark an invoice as viewed, only if the user is registered to the client.
  """
  def view_invoice(
        %Scope{user: %User{client_id: client_id}},
        %Schema.Invoice{client_id: client_id} = invoice
      ) do
    invoice
    |> Schema.Invoice.view_changeset()
    |> Repo.update()

    :ok
  end

  def view_invoice(_scope, _invoice), do: nil
end
