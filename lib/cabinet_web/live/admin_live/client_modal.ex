defmodule CabinetWeb.AdminLive.ClientModal do
  use CabinetWeb, :live_component

  alias Cabinet.Schema.Client

  @impl true
  def render(assigns) do
    ~H"""
    <dialog id={@id} open class="modal">
      <div class="modal-box">
        <.header>
          <p>{if @client, do: "Edit", else: "Add New"} Client</p>
        </.header>

        <.form
          :let={f}
          for={@form}
          id={"#{@id}_form"}
          phx-target={@myself}
          phx-submit="submit"
          phx-change="validate"
        >
          <.input field={f[:name]} label="Client Name" />
          <.input field={f[:shortcode]} label="Client Shortcode" />

          <%!-- <.input --%>
          <%!--   :for={{line, n} <- Enum.with_index(f[:address].value)} --%>
          <%!--   name={f[:address].name <> "[]"} --%>
          <%!--   value={line} --%>
          <%!--   label={"Client Address Line #{n + 1}"} --%>
          <%!-- /> --%>
          <%!-- <.button phx-click="new-address-line" phx-target={@myself}>Add Line</.button> --%>

          <.button variant="primary" type="submit">
            {if @client, do: "Save", else: "Create Client"}
          </.button>
        </.form>
      </div>
    </dialog>
    """
  end

  @impl true
  def update(assigns, socket) do
    client = assigns[:client] || %Client{}

    form =
      client
      |> Client.create_changeset(%{})
      |> to_form()

    {:ok, assign(socket, id: assigns.id, client: client, form: form)}
  end

  @impl true
  def handle_event("submit", params, socket) do
    %{"client" => client_params} = params

    case Client.create_changeset(socket.assigns.client, client_params) do
      %{valid?: true} = changeset ->
        send(self(), {:submit_client, changeset})
        {:noreply, socket}

      changeset ->
        {:noreply, assign(socket, :form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate", params, socket) do
    %{"client" => client_params} = params

    form =
      socket.assigns.client
      |> Client.create_changeset(client_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end
end
