defmodule CabinetWeb.PageController do
  use CabinetWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
