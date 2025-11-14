defmodule CabinetWeb.AdminLive.Invoice.FormComponent do
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
        <.input
          field={f[:client_id]}
          label="Client"
          type="select"
          options={@client_options}
          value={@client_id}
          readonly={!is_nil(@client_id)}
        />

        <.input field={f[:due]} label="Due Date" type="date" />
        <.input field={f[:term]} label="Terms" type="textarea" />

        <div class="flex mt-4 gap-2 justify-end">
          <.button phx-click={@cancel} type="button">Cancel</.button>
          <.button variant="primary" type="submit">
            {if @invoice, do: "Save", else: "Create Invoice"}
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    new? = is_nil(assigns[:invoice])
    invoice = assigns[:invoice] || %Invoice{}

    initial_params =
      if new? do
        %{due: Date.utc_today()}
      else
        %{}
      end

    client_options =
      for c <- assigns.clients do
        {c.name, c.id}
      end

    socket =
      socket
      |> assign(:invoice, invoice)
      |> assign(:client_id, invoice.client_id || assigns[:client_id])
      |> assign(:cancel, assigns[:cancel])
      |> assign(:client_options, client_options)
      |> assign_form(initial_params)

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
