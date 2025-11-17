defmodule CabinetWeb.AdminLive.Common do
  use Phoenix.Component

  import CabinetWeb.Util
  import CabinetWeb.CoreComponents

  attr :invoices, :list
  attr :row_click, {:fun, 1}
  attr :new_click, :string

  attr :show_client, :boolean, default: false

  def invoice_table(assigns) do
    ~H"""
    <.table
      id="invoice_list"
      rows={@invoices}
      row_click={@row_click}
    >
      <:col :let={{_, i}} label="#">{format_refnum(i.id)}</:col>
      <:col :let={{_, i}} :if={@show_client} label="Client">
        {if i.client, do: i.client.shortcode}
      </:col>
      <:col :let={{_, i}} label="Due Date">{i.due}</:col>
      <:col :let={{_, i}} label="Status">
        <p :if={i.late?} class="text-warning">Late</p>
        <p :if={!i.late?} class="text-base-content">Not Due</p>
        <%!-- <p :if={!i.paid?} class="text-success">Paid</p> --%>
      </:col>
    </.table>
    """
  end
end
