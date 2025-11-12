defmodule CabinetWeb.AdminLive do
  use CabinetWeb, :live_view

  alias Cabinet.Invoices

  alias CabinetWeb.AdminLive

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Admin Home")
      |> assign(clients: Invoices.list_clients(socket.assigns.current_scope))
      |> assign(selected_client: nil)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full grid grid-rows-[auto_1fr]">
      <Layouts.app_header current_scope={@current_scope} />

      <div class="bg-base-200">
        <div class="grid grid-cols-[auto_auto_1fr] w-full h-full">
          <nav class="w-full lg:w-80 border-r border-base-300 shadow-md flex flex-col">
            <ul class="grow">
              <li :for={client <- @clients}>{client.name}</li>
            </ul>
            <div class="flex flex-col px-2 py-1">
              <.button variant="primary" onclick="client_modal.showModal()">
                <.icon name="hero-user-plus-solid" />
                Add Client
              </.button>
            </div>
          </nav>
        </div>
      </div>
    </div>

    <.live_component module={AdminLive.ClientModal} id="client_modal" client={@selected_client}></.live_component>
    """
  end

  @impl true
  def handle_event("add_client", _params, socket) do

    {:noreply, socket}
  end
end
