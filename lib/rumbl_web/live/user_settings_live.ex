defmodule RumblWeb.UserSettingsLive do
  use RumblWeb, :live_view

  alias Rumbl.Accounts

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto">
      <!-- Header -->
      <div class="page-header">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-2xl font-bold text-wood-900">Account Settings</h1>
            <p class="mt-1 text-sm text-wood-600">
              Manage your account email address and password settings
            </p>
          </div>
          <div class="flex items-center space-x-3">
            <div class="w-10 h-10 bg-wood-600 rounded-full flex items-center justify-center">
              <span class="text-white font-medium text-sm">
                <%= String.first(@current_email) |> String.upcase() %>
              </span>
            </div>
            <div>
              <p class="text-sm font-medium text-wood-900"><%= @current_email %></p>
              <p class="text-xs text-wood-600">Account holder</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Settings Cards -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        
        <!-- Email Settings Card -->
        <div class="card">
          <div class="card-header">
            <div class="flex items-center">
              <div class="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center mr-3">
                <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                </svg>
              </div>
              <div>
                <h3 class="text-lg font-medium text-gray-900">Email Address</h3>
                <p class="text-sm text-gray-600">Update your email address</p>
              </div>
            </div>
          </div>
          <div class="card-body">
            <.simple_form
              for={@email_form}
              id="email_form"
              phx-submit="update_email"
              phx-change="validate_email"
            >
              <div class="form-group">
                <.input 
                  field={@email_form[:email]} 
                  type="email" 
                  label="New email address" 
                  class="form-input"
                  placeholder="Enter new email"
                  required 
                />
              </div>
              
              <div class="form-group">
                <.input
                  field={@email_form[:current_password]}
                  name="current_password"
                  id="current_password_for_email"
                  type="password"
                  label="Current password"
                  class="form-input"
                  placeholder="Confirm with current password"
                  value={@email_form_current_password}
                  required
                />
              </div>

              <:actions>
                <.button phx-disable-with="Updating..." class="btn-primary w-full">
                  <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"/>
                  </svg>
                  Update Email
                </.button>
              </:actions>
            </.simple_form>

            <div class="mt-4 p-3 bg-amber-50 border border-amber-200 rounded-md">
              <div class="flex">
                <svg class="w-4 h-4 text-amber-600 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
                </svg>
                <p class="ml-2 text-sm text-amber-700">
                  A confirmation link will be sent to your new email address.
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Password Settings Card -->
        <div class="card">
          <div class="card-header">
            <div class="flex items-center">
              <div class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center mr-3">
                <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
                </svg>
              </div>
              <div>
                <h3 class="text-lg font-medium text-gray-900">Password</h3>
                <p class="text-sm text-gray-600">Update your password</p>
              </div>
            </div>
          </div>
          <div class="card-body">
            <.simple_form
              for={@password_form}
              id="password_form"
              action={~p"/users/log_in?_action=password_updated"}
              method="post"
              phx-change="validate_password"
              phx-submit="update_password"
              phx-trigger-action={@trigger_submit}
            >
              <input
                name={@password_form[:email].name}
                type="hidden"
                id="hidden_user_email"
                value={@current_email}
              />
              
              <div class="form-group">
                <.input 
                  field={@password_form[:password]} 
                  type="password" 
                  label="New password" 
                  class="form-input"
                  placeholder="Enter new password"
                  required 
                />
              </div>
              
              <div class="form-group">
                <.input
                  field={@password_form[:password_confirmation]}
                  type="password"
                  label="Confirm new password"
                  class="form-input"
                  placeholder="Confirm new password"
                />
              </div>
              
              <div class="form-group">
                <.input
                  field={@password_form[:current_password]}
                  name="current_password"
                  type="password"
                  label="Current password"
                  class="form-input"
                  placeholder="Enter current password"
                  id="current_password_for_password"
                  value={@current_password}
                  required
                />
              </div>

              <:actions>
                <.button phx-disable-with="Updating..." class="btn-primary w-full">
                  <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"/>
                  </svg>
                  Update Password
                </.button>
              </:actions>
            </.simple_form>

            <div class="mt-4 p-3 bg-green-50 border border-green-200 rounded-md">
              <div class="flex">
                <svg class="w-4 h-4 text-green-600 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>
                </svg>
                <p class="ml-2 text-sm text-green-700">
                  You'll be logged out and need to sign in again after changing your password.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Additional Security Settings -->
      <div class="mt-8 card">
        <div class="card-header">
          <div class="flex items-center">
            <div class="w-8 h-8 bg-red-100 rounded-lg flex items-center justify-center mr-3">
              <svg class="w-4 h-4 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
              </svg>
            </div>
            <div>
              <h3 class="text-lg font-medium text-gray-900">Account Security</h3>
              <p class="text-sm text-gray-600">Additional security options</p>
            </div>
          </div>
        </div>
        <div class="card-body">
          <div class="space-y-4">
            
            <!-- Last Login Info -->
            <div class="flex items-center justify-between py-3 border-b border-gray-200">
              <div>
                <h4 class="text-sm font-medium text-gray-900">Last login</h4>
                <p class="text-sm text-gray-600">Monitor your account activity</p>
              </div>
              <span class="text-sm text-gray-500">Currently logged in</span>
            </div>

            <!-- Two-Factor Authentication (Future) -->
            <div class="flex items-center justify-between py-3 border-b border-gray-200">
              <div>
                <h4 class="text-sm font-medium text-gray-900">Two-factor authentication</h4>
                <p class="text-sm text-gray-600">Add an extra layer of security</p>
              </div>
              <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                Coming soon
              </span>
            </div>

            <!-- Account Deletion -->
            <div class="flex items-center justify-between py-3">
              <div>
                <h4 class="text-sm font-medium text-red-900">Delete account</h4>
                <p class="text-sm text-red-600">Permanently delete your account and all data</p>
              </div>
              <button 
                type="button" 
                class="btn-danger"
                onclick="alert('Account deletion feature coming soon')"
              >
                Delete Account
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
