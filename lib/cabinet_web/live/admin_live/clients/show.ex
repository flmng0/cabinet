defmodule CabinetWeb.AdminLive.Clients.Show do
  use CabinetWeb, :live_view

  alias Cabinet.Invoices

  embed_templates "client_*"

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    client = Invoices.get_client(socket.assigns.current_scope, id)

    socket =
      socket
      |> assign(:client, client)
      |> assign(:page_title, client.name <> " - Clients")

    {:noreply, socket}
  end

  attr :client, Cabinet.Schema.Client
  def client_view(assigns)

  attr :client, Cabinet.Schema.Client
  def client_edit(assigns)

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_scope={@current_scope}>
      <nav class="pb-4">
        <.link navigate={~p"/admin/clients"} class="text-secondary text-sm group relative">
          <.icon name="hero-arrow-long-left" class="size-4 -translate-y-1/2 top-1/2 group-hover:-translate-x-2 -translate-x-1 absolute right-full" />
          Return to Clients
        </.link>
      </nav>

      <.client_view :if={@live_action == :view} client={@client} />
      <.client_edit :if={@live_action == :edit} client={@client} />
    </Layouts.admin>
    """
  end

  @impl true
  def handle_info({:submit_client, attrs}, socket) do
    with {:ok, client} <- Invoices.update_client(socket.assigns.current_scope, socket.assigns.client, attrs) do
      socket =
        socket
        |> assign(:client, client)
        |> push_patch(to: ~p"/admin/clients/#{client.id}")

      {:noreply, socket}
    else
      _ -> {:noreply, socket}
    end
  end
end
