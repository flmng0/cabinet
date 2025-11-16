defmodule CabinetWeb.UserLive.Login do
  use CabinetWeb, :live_view

  alias Cabinet.Auth

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app>
      <div class="mx-auto max-w-sm space-y-4">
        <div class="text-center">
          <.header>
            <p>Log in</p>
            <:subtitle :if={!@current_scope}>
              Please log in to view your invoices.
            </:subtitle>
            <:subtitle :if={@current_scope}>
              You need to reauthenticate to perform sensitive actions on your account.
            </:subtitle>
          </.header>
        </div>

        <div :if={local_mail_adapter?()} class="alert alert-info">
          <.icon name="hero-information-circle" class="size-6 shrink-0" />
          <div>
            <p>You are running the local mail adapter.</p>
            <p>
              To see sent emails, visit <.link href="/dev/mailbox" class="underline">the mailbox page</.link>.
            </p>
          </div>
        </div>

        <.form
          :let={f}
          :if={!@submitted}
          for={@form}
          id="login_form"
          action={~p"/users/log-in"}
          phx-submit="submit"
        >
          <.input
            readonly={!!@current_scope}
            field={f[:email]}
            type="email"
            label="Email"
            autocomplete="username"
            required
            phx-mounted={JS.focus()}
          />
          <.button class="btn btn-primary w-full">
            Log in with email <span aria-hidden="true">→</span>
          </.button>
        </.form>

        <div :if={@submitted} class="alert alert-success">
          <.icon name="hero-check-circle" class="size-6 shrink-0" />
          <div>
            <p class="text-lg font-mono">Log-in Submitted Successfully</p>
            <p>
              If your email is in our system, you will receive instructions for logging in shortly.
            </p>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    title =
      if socket.assigns.current_scope do
        "Re-Authenticate"
      else
        "Log In"
      end

    {:ok, assign(socket, form: form, submitted: false, page_title: title)}
  end

  @impl true
  def handle_event("submit", %{"user" => %{"email" => email}}, socket) do
    if user = Auth.get_user_by_email(email) do
      Auth.deliver_login_instructions(
        user,
        &url(~p"/users/log-in/#{&1}")
      )
    end

    {:noreply, assign(socket, form: nil, submitted: true)}
  end

  defp local_mail_adapter? do
    Application.get_env(:cabinet, Cabinet.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
