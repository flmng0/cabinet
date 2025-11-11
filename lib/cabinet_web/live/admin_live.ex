defmodule CabinetWeb.AdminLive do
  use CabinetWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <h1>Hello, admin!</h1>
    </Layouts.app>
    """
  end
end
