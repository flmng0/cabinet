defmodule CabinetWeb.InvoiceController do
  use CabinetWeb, :controller

  @refnum_prefix "INV-"
  alias Cabinet.Invoices

  def index(conn, _params) do
    if invoices = Invoices.list_invoices(conn.assigns.current_scope, full?: true) do
      conn
      |> assign_business()
      |> assign(:invoices, invoices)
      |> assign(:page_title, "View Invoices")
      |> render(:index)
    else
      raise CabinetWeb.NotFoundError, "Client has no invoices"
    end
  end

  def view(conn, %{"refnum" => refnum}) do
    with {:ok, refnum} <- parse_refnum(refnum) do
      if invoice = Invoices.get_invoice(conn.assigns.current_scope, refnum, full?: true) do
        Invoices.view_invoice(conn.assigns.current_scope, invoice)

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
      id: 128,
      term: nil,
      due: ~D"2025-10-27",
      late?: true,
      days_overdue: 3,
      subtotal: Decimal.new("480.0000"),
      total_gst: Decimal.new("0.000"),
      amount_due: Decimal.new("480.000"),
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
  end
end
