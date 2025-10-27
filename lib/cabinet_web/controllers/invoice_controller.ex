defmodule CabinetWeb.InvoiceController do
  use CabinetWeb, :controller

  def assign_business(conn) do
    business = Application.fetch_env!(:cabinet, :business)

    Enum.reduce(business, conn, fn {key, val}, conn -> assign(conn, key, val) end)
  end

  def view(conn, _params) do
    conn
      |> assign_business()
      |> render(:view)
  end
end
