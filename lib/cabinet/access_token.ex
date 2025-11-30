defmodule Cabinet.AccessToken do
  defstruct invoice_id: nil

  alias CabinetWeb.Endpoint

  def sign(%Cabinet.Schema.Invoice{id: id}) do
    Phoenix.Token.sign(Endpoint, "invoice access token", id)
  end

  def verify_token(Cabinet.Schema.Invoice, token) do
    case Phoenix.Token.verify(Endpoint, "invoice access token", token, max_age: 604_800) do
      {:ok, invoice_id} ->
        %__MODULE__{invoice_id: invoice_id}

      {:error, _err} ->
        nil
    end
  end
end
