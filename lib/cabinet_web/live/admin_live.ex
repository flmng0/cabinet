defmodule CabinetWeb.AdminLive do
  use CabinetWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, push_navigate(socket, to: ~p"/admin/clients")}
  end
end
