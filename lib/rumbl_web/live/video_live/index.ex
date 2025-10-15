defmodule RumblWeb.VideoLive.Index do
  use RumblWeb, :live_view

  alias Rumbl.Multimedia
  alias Rumbl.Multimedia.Video

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to video updates for real-time functionality
      Phoenix.PubSub.subscribe(Rumbl.PubSub, "videos")
    end

    {:ok, 
     socket
     |> assign(:page_title, "My Videos")
     |> Phoenix.LiveView.stream_configure(:videos, dom_id: &"video-#{&1.id}")
     |> Phoenix.LiveView.stream(:videos, list_videos(socket))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Video")
    |> assign(:video, Multimedia.get_user_video!(current_user(socket), id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Video")
    |> assign(:video, %Video{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "My Videos")
    |> assign(:video, nil)
  end

  # Handle messages and real-time updates
  @impl true
  def handle_info({RumblWeb.VideoLive.FormComponent, {:saved, video}}, socket) do
    {:noreply, Phoenix.LiveView.stream_insert(socket, :videos, video)}
  end

  @impl true
  def handle_info({:video_created, video}, socket) do
    user = current_user(socket)
    if video.user_id == user.id do
      {:noreply, Phoenix.LiveView.stream_insert(socket, :videos, video)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:video_updated, video}, socket) do
    user = current_user(socket)
    if video.user_id == user.id do
      {:noreply, Phoenix.LiveView.stream_insert(socket, :videos, video)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:video_deleted, video}, socket) do
    user = current_user(socket)
    if video.user_id == user.id do
      {:noreply, Phoenix.LiveView.stream_delete(socket, :videos, video)}
    else
      {:noreply, socket}
    end
  end

  # Handle events
  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    video = Multimedia.get_video!(id)
    
    if video.user_id == socket.assigns.current_user.id do
      {:ok, _} = Multimedia.delete_video(video)
      Phoenix.PubSub.broadcast!(Rumbl.PubSub, "video_updates", {:video_deleted, video})
      {:noreply, Phoenix.LiveView.stream_delete(socket, :videos, video)}
    else
      {:noreply, put_flash(socket, :error, "You can only delete your own videos.")}
    end
  end

  defp list_videos(socket) do
    Multimedia.list_user_videos(current_user(socket))
  end

  defp current_user(socket) do
    socket.assigns.current_user
  end
end