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
        <.input field={f[:title]} label="Title" />
        <.input field={f[:due]} label="Due Date" type="date" required />
        <.input field={f[:term]} label="Terms" type="textarea" />

        <div id="invoice_untis" phx-hook=".ReturnInsert" class="space-y-2">
          <label class="label text-sm block clear-both">Units</label>

          <.inputs_for :let={unit} field={f[:units]}>
            <div class="flex flex-row gap-2 mb-2">
              <input type="hidden" name="invoice[unit_sort][]" value={unit.index} />

              <label class="floating-label grow">
                <span :if={unit.index == 0}>Description</span>
                <.input
                  field={unit[:description]}
                  type="text"
                  container_class=""
                  phx-mounted={unit.index > 0 && JS.focus()}
                />
              </label>
              <label class="floating-label w-24">
                <span :if={unit.index == 0}>Count</span>
                <.input field={unit[:count]} type="number" container_class="" />
              </label>
              <label class="floating-label w-24">
                <span :if={unit.index == 0}>Cost ($)</span>
                <.input field={unit[:cost]} type="number" container_class="" />
              </label>

              <.button
                type="button"
                name="invoice[unit_drop][]"
                value={unit.index}
                phx-click={JS.dispatch("change")}
              >
                Delete
              </.button>
            </div>
          </.inputs_for>

          <input type="hidden" name="invoice[unit_drop][]" />

          <.button
            type="button"
            name="invoice[unit_sort][]"
            value="new"
            phx-click={JS.dispatch("change")}
          >
            Add New
          </.button>
        </div>

        <div class="flex mt-4 gap-2 justify-end">
          <.button phx-click={@cancel} type="button">Cancel</.button>
          <.button variant="primary" type="submit">
            {if @invoice, do: "Save", else: "Create Invoice"}
          </.button>
        </div>
      </.form>
      <script :type={Phoenix.LiveView.ColocatedHook} name=".ReturnInsert">
        export default {
          mounted() {
            const addButton = this.el.querySelector("button[value=new]");

            this.el.addEventListener("keypress", (e) => {
              if (e.key === "Enter" && e.target.tagName === "INPUT") {
                e.preventDefault();
                addButton.click();
              }
            });
          }
        }
      </script>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    invoice = assigns.invoice

    initial_params =
      if Enum.empty?(invoice.units) do
        %{units: [%{}]}
      else
        %{}
      end

    socket =
      socket
      |> assign(:invoice, invoice)
      |> assign(:cancel, assigns[:cancel])
      |> assign_form(initial_params)

    {:ok, socket}
  end

  defp assign_form(socket, params, opts \\ []) do
    form =
      socket.assigns.invoice
      |> Invoice.changeset(params)
      |> to_form(opts ++ [as: "invoice"])

    assign(socket, :form, form)
  end

  @impl true
  def handle_event("submit", %{"invoice" => invoice_params}, socket) do
    case Invoice.changeset(socket.assigns.invoice, invoice_params) do
      %{valid?: true} = _changeset ->
        send(self(), {:submit_invoice, invoice_params})
        {:noreply, socket}

      changeset ->
        {:noreply, assign(socket, :form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate", %{"invoice" => invoice_params}, socket) do
    {:noreply, assign_form(socket, invoice_params, action: :validate)}
  end
end
