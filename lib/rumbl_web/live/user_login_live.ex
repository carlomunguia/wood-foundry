defmodule RumblWeb.UserLoginLive do
  use RumblWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-wood-50 to-wood-100 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <!-- Logo and Brand -->
        <div class="flex justify-center">
          <div class="w-12 h-12 bg-wood-600 rounded-xl flex items-center justify-center">
            <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 20 20">
              <path d="M3 4a1 1 0 011-1h12a1 1 0 011 1v2a1 1 0 01-1 1H4a1 1 0 01-1-1V4zM3 10a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H4a1 1 0 01-1-1v-6zM14 9a1 1 0 00-1 1v6a1 1 0 001 1h2a1 1 0 001-1v-6a1 1 0 00-1-1h-2z"/>
            </svg>
          </div>
        </div>
        <h2 class="mt-6 text-center text-3xl font-bold text-wood-900">
          Welcome back
        </h2>
        <p class="mt-2 text-center text-sm text-wood-600">
          Sign in to Pink Ivory Foundry
        </p>
      </div>

      <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div class="card">
          <div class="card-body">
            <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
              <div class="form-group">
                <.input
                  field={@form[:email]}
                  type="email"
                  label="Email address"
                  class="form-input"
                  placeholder="Enter your email"
                  required
                />
              </div>

              <div class="form-group">
                <.input
                  field={@form[:password]}
                  type="password"
                  label="Password"
                  class="form-input"
                  placeholder="Enter your password"
                  required
                />
              </div>

              <div class="flex items-center justify-between">
                <.input
                  field={@form[:remember_me]}
                  type="checkbox"
                  label="Keep me logged in"
                  class="h-4 w-4 text-wood-600 focus:ring-wood-500 border-gray-300 rounded"
                />
                <.link href={~p"/users/reset_password"} class="text-sm font-medium text-wood-600 hover:text-wood-500">
                  Forgot password?
                </.link>
              </div>

              <:actions>
                <.button phx-disable-with="Signing in..." class="btn-primary w-full">
                  Sign in <span aria-hidden="true">→</span>
                </.button>
              </:actions>
            </.simple_form>

            <!-- Social Login Preparation -->
            <div class="mt-6">
              <div class="relative">
                <div class="absolute inset-0 flex items-center">
                  <div class="w-full border-t border-gray-300"></div>
                </div>
                <div class="relative flex justify-center text-sm">
                  <span class="px-2 bg-white text-gray-500">Or continue with</span>
                </div>
              </div>

              <div class="mt-6 grid grid-cols-2 gap-3">
                <button
                  type="button"
                  class="w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-500 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                  disabled
                  title="Coming soon"
                >
                  <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 0C4.477 0 0 4.484 0 10.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0110 4.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.203 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.942.359.31.678.921.678 1.856 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0020 10.017C20 4.484 15.522 0 10 0z" clip-rule="evenodd"/>
                  </svg>
                  <span class="ml-2">GitHub</span>
                </button>

                <button
                  type="button"
                  class="w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-500 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                  disabled
                  title="Coming soon"
                >
                  <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                    <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                    <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                    <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                  </svg>
                  <span class="ml-2">Google</span>
                </button>
              </div>
            </div>

            <div class="mt-6 text-center">
              <p class="text-sm text-gray-600">
                Don't have an account?
                <.link navigate={~p"/users/register"} class="font-medium text-wood-600 hover:text-wood-500 underline">
                  Sign up here
                </.link>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
