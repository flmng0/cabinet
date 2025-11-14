defmodule CabinetWeb.InvoiceController do
  use CabinetWeb, :controller

  @refnum_prefix "INV-"
  alias Cabinet.Invoices

  def index(conn, _params) do
    # Cabinet.Invoices.get_invoices(conn.assigns.current_scope)
    view_mock(conn, _params)
  end

  def view(conn, %{"client" => client, "refnum" => refnum} = _params) do
    with {:ok, refnum} <- parse_refnum(refnum) do
      if invoice = Invoices.get_invoice(client, refnum, full?: true) do
        conn
        |> assign_business()
        |> assign_invoice(invoice)
        |> render(:view)
      else
        raise CabinetWeb.NotFoundError, "No such invoice found"
      end
    else
      :invalid_refnum ->
        raise CabinetWeb.RequestError, "Failed to parse invoice reference number"
    end
  end

  def view_mock(conn, _params) do
    conn
    |> assign_business()
    |> assign_invoice(mock_invoice())
    |> render(:view)
  end

  defp assign_invoice(conn, %Cabinet.Schema.Invoice{id: id} = invoice) do
    conn
    |> assign(:invoice, invoice)
    |> assign(:page_title, CabinetWeb.Util.format_refnum(id))
  end

  defp assign_business(conn) do
    business = Application.fetch_env!(:cabinet, :business)

    Enum.reduce(business, conn, fn {key, val}, conn -> assign(conn, key, val) end)
  end

  defp parse_refnum(@refnum_prefix <> num) do
    with {num, ""} <- Integer.parse(num) do
      {:ok, num}
    else
      _ -> :invalid_refnum
    end
  end

  defp parse_refnum(_), do: :invalid_refnum

  alias Cabinet.Schema.{Invoice, Client, Unit}

  defp mock_invoice() do
    %Invoice{
      id: 1,
      term: nil,
      due: ~D"2025-10-27",
      inserted_at: ~D"2025-10-20",
      gst: false,
      units: [
        %Unit{
          description: "Analysis of system requirements",
          cost: Decimal.new("40.00"),
          count: 2
        },
        %Unit{
          description: "Development hours",
          cost: Decimal.new("40.00"),
          count: 10
        }
      ],
      client: %Client{
        name: "Chicken McMart",
        shortcode: "chmm",
        address: "32 Fake Street\nSUBITHA WZ 2025"
      }
    }
    |> Cabinet.Invoices.with_virtual_fields()
  end
end
