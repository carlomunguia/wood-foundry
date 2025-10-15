defmodule RumblWeb.WatchLive do
  use RumblWeb, :live_view

  alias Rumbl.Multimedia
  alias Rumbl.Multimedia.Annotation

  @impl true
  def mount(%{"id" => video_id}, _session, socket) do
    video = Multimedia.get_video!(video_id)
    
    if connected?(socket) do
      # Subscribe to annotation updates for this video
      Phoenix.PubSub.subscribe(Rumbl.PubSub, "video_annotations:#{video_id}")
      # Also subscribe to user presence updates
      Phoenix.PubSub.subscribe(Rumbl.PubSub, "video_presence:#{video_id}")
    end

    annotations = Multimedia.list_annotations(video)
    
    # Track user presence
    if connected?(socket) do
      track_user_presence(socket, video_id)
    end

    {:ok,
     socket
     |> assign(:video, video)
     |> assign(:annotations, annotations)
     |> assign(:annotation_form, to_form(%Annotation{} |> Annotation.changeset(%{})))
     |> assign(:current_time, 0)
     |> assign(:users_online, [])
     |> assign(:page_title, video.title)}
  end

  @impl true
  def handle_event("validate_annotation", %{"annotation" => annotation_params}, socket) do
    changeset = 
      %Annotation{}
      |> Annotation.changeset(annotation_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :annotation_form, to_form(changeset))}
  end

  @impl true
  def handle_event("save_annotation", %{"annotation" => annotation_params}, socket) do
    user = socket.assigns.current_user
    video_id = socket.assigns.video.id

    case Multimedia.annotate_video(user, video_id, annotation_params) do
      {:ok, annotation} ->
        # Broadcast the new annotation to all viewers
        Phoenix.PubSub.broadcast!(
          Rumbl.PubSub,
          "video_annotations:#{video_id}",
          {:new_annotation, annotation}
        )

        # Reset the form
        new_form = to_form(%Annotation{} |> Annotation.changeset(%{}))

        {:noreply, 
         socket
         |> assign(:annotation_form, new_form)
         |> put_flash(:info, "Annotation added!")}

      {:error, changeset} ->
        {:noreply, assign(socket, :annotation_form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event("update_time", %{"time" => time}, socket) do
    {:noreply, assign(socket, :current_time, time)}
  end

  @impl true
  def handle_event("seek_to", %{"time" => time}, socket) do
    # This will be handled by JavaScript to seek the video player
    {:noreply, push_event(socket, "seek_video", %{time: time})}
  end

  # Handle real-time annotation updates
  @impl true
  def handle_info({:new_annotation, annotation}, socket) do
    updated_annotations = [annotation | socket.assigns.annotations]
    {:noreply, assign(socket, :annotations, updated_annotations)}
  end

  @impl true
  def handle_info({:user_joined, user}, socket) do
    updated_users = [user | socket.assigns.users_online] |> Enum.uniq_by(& &1.id)
    {:noreply, assign(socket, :users_online, updated_users)}
  end

  @impl true
  def handle_info({:user_left, user}, socket) do
    updated_users = Enum.reject(socket.assigns.users_online, &(&1.id == user.id))
    {:noreply, assign(socket, :users_online, updated_users)}
  end

  # Helper functions
  defp track_user_presence(socket, video_id) do
    if socket.assigns[:current_user] do
      Phoenix.PubSub.broadcast!(
        Rumbl.PubSub,
        "video_presence:#{video_id}",
        {:user_joined, socket.assigns.current_user}
      )
    end
  end

  defp player_id(video) do
    Regex.named_captures(~r".*(?:youtu\.be/|v/|u/\w/|embed/|watch\?v=)(?<id>[^#&?]*)", video.url)["id"]
  end

  defp format_time(seconds) do
    minutes = div(seconds, 60)
    remaining_seconds = rem(seconds, 60)
    "#{minutes}:#{String.pad_leading(to_string(remaining_seconds), 2, "0")}"
  end
end