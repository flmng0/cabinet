defmodule CabinetWeb.PageController do
  use CabinetWeb, :controller

  def home(conn, _params) do
    business = Application.fetch_env!(:cabinet, :business)

    conn = assign(conn, :contact_name, business[:contact_name])

    if conn.assigns.current_scope do
      conn
      |> assign(:new_count, 0)
      |> render(:index)
    else
      render(conn, :welcome)
    end
  end
end
