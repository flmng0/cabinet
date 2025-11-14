defmodule CabinetWeb.AdminLive.Client.FormComponent do
  use CabinetWeb, :live_component

  alias Cabinet.Schema.Client

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        :let={f}
        for={@form}
        phx-target={@myself}
        phx-submit="submit"
        phx-change="validate"
      >
        <.input field={f[:name]} label="Client Name" required />
        <.input field={f[:shortcode]} label="Client Shortcode" required />

        <.input field={f[:address]} type="textarea" label="Client Address" />

        <div class="flex mt-4 gap-2 justify-end">
          <.button phx-click={@cancel} type="button">Cancel</.button>
          <.button variant="primary" type="submit">
            {if @client, do: "Save", else: "Create Client"}
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(:client, assigns[:client] || %Client{})
      |> assign(:cancel, assigns.cancel)
      |> assign_form(%{})

    {:ok, socket}
  end

  defp assign_form(socket, params, opts \\ []) do
    form =
      socket.assigns.client
      |> Client.changeset(params)
      |> to_form(opts)

    assign(socket, :form, form)
  end

  @impl true
  def handle_event("submit", %{"client" => client_params}, socket) do
    case Client.changeset(socket.assigns.client, client_params) do
      %{valid?: true} = _changeset ->
        send(self(), {:submit_client, client_params})
        {:noreply, socket}

      changeset ->
        {:noreply, assign(socket, :form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate", %{"client" => client_params}, socket) do
    {:noreply, assign_form(socket, client_params, action: :validate)}
  end
end
