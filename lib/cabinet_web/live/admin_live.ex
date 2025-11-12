defmodule CabinetWeb.AdminLive do
  use CabinetWeb, :live_view

  alias Cabinet.Invoices

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream(:clients, Invoices.list_clients(socket.assigns.current_scope))
      |> assign(client: nil, show_client_modal: false)
      |> assign(page_title: "Admin Home")

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_scope={@current_scope}>
      <.header>
        <p>Registered Clients</p>
        <:actions>
          <.button variant="primary" phx-click="new-client">
            <.icon name="hero-user-plus-solid" /> Create New Client
          </.button>
        </:actions>
      </.header>
      <.table id="client_list" rows={@streams[:clients]}>
        <:col :let={{_, c}} label="Shortcode">{c.shortcode}</:col>
        <:col :let={{_, c}} label="Name">{c.name}</:col>

        <:action :let={{_, c}}>
          <.button phx-click="view-client" phx-data-client={c.id}>
            <.icon name="hero-arrow-long-right" />
          </.button>
        </:action>
      </.table>

      <.live_component
        :if={@show_client_modal}
        id="client_modal"
        module={CabinetWeb.AdminLive.ClientModal}
        client={@client}
      />
    </Layouts.admin>
    """
  end

  @impl true
  def handle_event("new-client", _params, socket) do
    {:noreply, assign(socket, :show_client_modal, true)}
  end

  def handle_event("view-client", %{"client" => _client_id}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:submit_client, %Ecto.Changeset{} = changeset}, socket) do
    with {:ok, client} <- Invoices.upsert_client(socket.assigns.current_scope, changeset) do
      IO.inspect(client, label: "client")
      {:noreply, socket}
    else
      _ -> {:noreply, socket}
    end
  end
end
