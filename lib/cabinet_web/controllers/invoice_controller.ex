defmodule CabinetWeb.InvoiceController do
  use CabinetWeb, :controller

  alias Cabinet.Schema.{Invoice, Client, Unit}

  defp mock_invoice() do
    %Invoice{
      term: nil,
      due: ~D"2025-10-27",
      refnum: 1,
      inserted_at: ~D"2025-10-20",
      units: [
        %Unit{
          description: "Analysis of system requirements",
          cost: Decimal.new(1, 4000, -2),
          count: 2
        },
        %Unit{
          description: "Development hours",
          cost: Decimal.new(1, 4000, -2),
          count: 10
        }
      ],
      client: %Client{
        name: "Chicken McMart",
        shortcode: "chmm",
        address: [
          "32 Fake Street",
          "SUBITHA WZ 2025"
        ]
      }
    }
  end

  def assign_business(conn) do
    business = Application.fetch_env!(:cabinet, :business)

    Enum.reduce(business, conn, fn {key, val}, conn -> assign(conn, key, val) end)
  end

  def view(conn, _params) do
    conn
    |> assign_business()
    |> assign(:invoice, mock_invoice())
    |> assign(:gst, true)
    |> render(:view)
  end
end
