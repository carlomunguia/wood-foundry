defmodule RumblWeb.UserRegistrationLive do
  use RumblWeb, :live_view

  alias Rumbl.Accounts
  alias Rumbl.Accounts.User

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
          Join Pink Ivory Foundry
        </h2>
        <p class="mt-2 text-center text-sm text-wood-600">
          Create your account to explore exotic wood videos
        </p>
      </div>

      <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div class="card">
          <div class="card-body">
            <.simple_form
              for={@form}
              id="registration_form"
              phx-submit="save"
              phx-change="validate"
              phx-trigger-action={@trigger_submit}
              action={~p"/users/log_in?_action=registered"}
              method="post"
            >
              <.error :if={@check_errors}>
                Oops, something went wrong! Please check the errors below.
              </.error>

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

              <!-- Enhanced Password Field with Strength Indicator -->
              <div 
                class="form-group" 
                x-data="{ 
                  password: '', 
                  strength: 0, 
                  showStrength: false,
                  getStrength(password) {
                    let score = 0;
                    if (password.length >= 8) score++;
                    if (/[A-Z]/.test(password)) score++;
                    if (/[a-z]/.test(password)) score++;
                    if (/[0-9]/.test(password)) score++;
                    if (/[^A-Za-z0-9]/.test(password)) score++;
                    return score;
                  },
                  getStrengthText(score) {
                    const levels = ['Very Weak', 'Weak', 'Fair', 'Good', 'Strong'];
                    return levels[score] || 'Very Weak';
                  },
                  getStrengthColor(score) {
                    const colors = ['bg-red-500', 'bg-orange-500', 'bg-yellow-500', 'bg-blue-500', 'bg-green-500'];
                    return colors[score] || 'bg-red-500';
                  }
                }"
                x-init="$watch('password', value => { 
                  strength = getStrength(value); 
                  showStrength = value.length > 0; 
                })"
              >
                <.input 
                  field={@form[:password]} 
                  type="password" 
                  label="Password" 
                  class="form-input"
                  placeholder="Choose a strong password"
                  required 
                />
                
                <!-- Password Strength Indicator -->
                <div x-show="showStrength" x-transition class="mt-2">
                  <div class="flex justify-between items-center mb-1">
                    <span class="text-sm font-medium text-gray-700">Password strength</span>
                    <span class="text-sm" x-text="getStrengthText(strength)" 
                          x-bind:class="{
                            'text-red-600': strength <= 1,
                            'text-orange-600': strength === 2,
                            'text-yellow-600': strength === 3,
                            'text-blue-600': strength === 4,
                            'text-green-600': strength === 5
                          }">
                    </span>
                  </div>
                  <div class="w-full bg-gray-200 rounded-full h-2">
                    <div 
                      class="h-2 rounded-full transition-all duration-300"
                      x-bind:class="getStrengthColor(strength)"
                      x-bind:style="'width: ' + (strength * 20) + '%'"
                    ></div>
                  </div>
                  <div class="mt-2 text-xs text-gray-600">
                    <ul class="space-y-1">
                      <li x-bind:class="password.length >= 8 ? 'text-green-600' : 'text-gray-600'">
                        <span x-show="password.length >= 8">✓</span>
                        <span x-show="password.length < 8">○</span>
                        At least 8 characters
                      </li>
                      <li x-bind:class="/[A-Z]/.test(password) ? 'text-green-600' : 'text-gray-600'">
                        <span x-show="/[A-Z]/.test(password)">✓</span>
                        <span x-show="!/[A-Z]/.test(password)">○</span>
                        One uppercase letter
                      </li>
                      <li x-bind:class="/[0-9]/.test(password) ? 'text-green-600' : 'text-gray-600'">
                        <span x-show="/[0-9]/.test(password)">✓</span>
                        <span x-show="!/[0-9]/.test(password)">○</span>
                        One number
                      </li>
                      <li x-bind:class="/[^A-Za-z0-9]/.test(password) ? 'text-green-600' : 'text-gray-600'">
                        <span x-show="/[^A-Za-z0-9]/.test(password)">✓</span>
                        <span x-show="!/[^A-Za-z0-9]/.test(password)">○</span>
                        One special character
                      </li>
                    </ul>
                  </div>
                </div>
              </div>

              <!-- Terms and Privacy -->
              <div class="form-group">
                <div class="flex items-start">
                  <input 
                    type="checkbox" 
                    id="terms" 
                    required
                    class="h-4 w-4 text-wood-600 focus:ring-wood-500 border-gray-300 rounded mt-1"
                  />
                  <label for="terms" class="ml-2 text-sm text-gray-600">
                    I agree to the 
                    <a href="#" class="text-wood-600 hover:text-wood-500 underline">Terms of Service</a>
                    and 
                    <a href="#" class="text-wood-600 hover:text-wood-500 underline">Privacy Policy</a>
                  </label>
                </div>
              </div>

              <:actions>
                <.button phx-disable-with="Creating account..." class="btn-primary w-full">
                  Create account
                </.button>
              </:actions>
            </.simple_form>

            <div class="mt-6 text-center">
              <p class="text-sm text-gray-600">
                Already have an account?
                <.link navigate={~p"/users/log_in"} class="font-medium text-wood-600 hover:text-wood-500 underline">
                  Sign in here
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
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
