defmodule CabinetWeb.AdminLive.ClientModal do
  use CabinetWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <dialog id={@id} class="modal">
      <div class="modal-box">
        <h2 class="text-lg">{if @client, do: "Edit", else: "Create"} Client</h2>

        <form method="dialog" phx-target={@myself} phx-submit="submit">
          <div class="modal-action">
            <.button variant="primary">
              {if @client, do: "Save", else: "Create"}
            </.button>
            <.button>Close</.button>
          </div>
        </form>
      </div>
    </dialog>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("submit", _params, socket) do
    {:noreply, socket}
  end
end
