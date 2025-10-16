defmodule RumblWeb.VideoLive.Show do
  use RumblWeb, :live_view

  alias Rumbl.Multimedia

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    video = Multimedia.get_video!(id)

    if video.user_id == socket.assigns.current_user.id do
      Phoenix.PubSub.subscribe(Rumbl.PubSub, "video_updates")

      {:noreply,
       socket
       |> assign(:page_title, page_title(socket.assigns.live_action))
       |> assign(:video, video)}
    else
      {:noreply,
       socket
       |> put_flash(:error, "You can only view your own videos.")
       |> redirect(to: ~p"/manage/videos")}
    end
  end

  @impl true
  def handle_info({RumblWeb.VideoLive.FormComponent, {:saved, video}}, socket) do
    {:noreply, assign(socket, :video, video)}
  end

  @impl true
  def handle_info({:video_updated, video}, socket) do
    if video.id == socket.assigns.video.id do
      {:noreply, assign(socket, :video, video)}
    else
      {:noreply, socket}
    end
  end

  defp page_title(:show), do: "Show Video"
  defp page_title(:edit), do: "Edit Video"
end
