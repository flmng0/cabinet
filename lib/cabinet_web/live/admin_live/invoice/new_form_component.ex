defmodule CabinetWeb.AdminLive.Invoice.NewFormComponent do
  use CabinetWeb, :live_component

  alias Cabinet.Schema.Invoice

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
        <.input field={f[:due]} label="Due Date" type="datetime-local" />
        <.input field={f[:term]} label="Terms" type="textarea" />

        <div class="flex mt-4 gap-2 justify-end">
          <.button phx-click={@cancel} type="button">Cancel</.button>
          <.button variant="primary" type="submit">
            {if @client, do: "Save", else: "Create Invoice"}
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    invoice = assigns[:invoice] || %Invoice{}

    socket =
      socket
      |> assign(:invoice, invoice)
      |> assign(:client, invoice.client || assigns[:client])
      |> assign(:cancel, assigns.cancel)
      |> assign_form(%{})

    {:ok, socket}
  end

  defp assign_form(socket, params, opts \\ []) do
    form =
      socket.assigns.invoice
      |> Invoice.changeset(params)
      |> to_form(opts)

    assign(socket, :form, form)
  end

  @impl true
  def handle_event("submit", %{"invoice" => client_params}, socket) do
    case Invoice.changeset(socket.assigns.invoice, client_params) do
      %{valid?: true} = _changeset ->
        send(self(), {:submit_invoice, client_params})
        {:noreply, socket}

      changeset ->
        {:noreply, assign(socket, :form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate", %{"invoice" => client_params}, socket) do
    {:noreply, assign_form(socket, client_params, action: :validate)}
  end
end
