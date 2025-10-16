defmodule RumblWeb.Router do
  use RumblWeb, :router

  import RumblWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, html: {RumblWeb.Layouts, :root}
    plug :fetch_current_user
    plug RumblWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RumblWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController, only: [:index, :show, :new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]

    live_session :public_videos,
      on_mount: [{RumblWeb.UserAuth, :mount_current_user}] do
      live "/watch/:id", WatchLive, :show
    end
  end

  scope "/manage", RumblWeb do
    pipe_through [:browser, :authenticate_user]

    live_session :authenticated_user,
      on_mount: [{RumblWeb.UserAuth, :ensure_authenticated}] do
      live "/videos", VideoLive.Index, :index
      live "/videos/new", VideoLive.Index, :new
      live "/videos/:id/edit", VideoLive.Index, :edit
      live "/videos/:id", VideoLive.Show, :show
      live "/videos/:id/show/edit", VideoLive.Show, :edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", RumblWeb do
  #   pipe_through :api
  # end

  ## Authentication routes

  scope "/", RumblWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{RumblWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", RumblWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{RumblWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", RumblWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{RumblWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
