defmodule RumblWeb.UserForgotPasswordLive do
  use RumblWeb, :live_view

  alias Rumbl.Accounts

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-wood-50 to-wood-100 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <!-- Logo and Brand -->
        <div class="flex justify-center">
          <div class="w-12 h-12 bg-wood-600 rounded-xl flex items-center justify-center">
            <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/>
            </svg>
          </div>
        </div>
        <h2 class="mt-6 text-center text-3xl font-bold text-wood-900">
          Reset your password
        </h2>
        <p class="mt-2 text-center text-sm text-wood-600">
          Enter your email and we'll send you a reset link
        </p>
      </div>

      <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div class="card">
          <div class="card-body">
            <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
              <div class="form-group">
                <.input
                  field={@form[:email]}
                  type="email"
                  label="Email address"
                  class="form-input"
                  placeholder="Enter your email address"
                  required
                />
              </div>

              <:actions>
                <.button phx-disable-with="Sending..." class="btn-primary w-full">
                  <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                  </svg>
                  Send reset instructions
                </.button>
              </:actions>
            </.simple_form>

            <div class="mt-6 text-center space-y-2">
              <p class="text-sm text-gray-600">
                Remember your password?
                <.link href={~p"/users/log_in"} class="font-medium text-wood-600 hover:text-wood-500 underline">
                  Sign in here
                </.link>
              </p>
              <p class="text-sm text-gray-600">
                Don't have an account?
                <.link href={~p"/users/register"} class="font-medium text-wood-600 hover:text-wood-500 underline">
                  Sign up here
                </.link>
              </p>
            </div>
          </div>
        </div>

        <!-- Security Notice -->
        <div class="mt-6 text-center">
          <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div class="flex items-center justify-center">
              <svg class="w-5 h-5 text-blue-600 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>
              </svg>
              <p class="text-sm text-blue-800">
                For security, we'll only send reset links to registered email addresses.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
