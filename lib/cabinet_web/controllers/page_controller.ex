defmodule CabinetWeb.PageController do
  use CabinetWeb, :controller

  def home(conn, _params) do
    business = Application.fetch_env!(:cabinet, :business)

    conn =
      conn
      |> assign(:contact_name, business[:contact_name])
      |> assign(:page_title, "Home")

    if scope = conn.assigns.current_scope do
      conn
      |> assign(:counts, Cabinet.Invoices.get_invoice_counts(scope))
      |> render(:index)
    else
      render(conn, :welcome)
    end
  end
end
