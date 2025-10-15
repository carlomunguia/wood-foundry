defmodule RumblWeb.VideoLive.FormComponent do
  use RumblWeb, :live_component

  alias Rumbl.Multimedia

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto">
      <div class="page-header">
        <h1 class="text-2xl font-bold text-wood-900"><%= @title %></h1>
        <p class="mt-1 text-sm text-wood-600">
          Upload a video file or provide a YouTube URL to add to your collection.
        </p>
      </div>

      <!-- Upload Method Selection -->
      <div class="mb-8" x-data="{ uploadMethod: 'file' }">
        <div class="sm:hidden">
          <select x-model="uploadMethod" class="form-input">
            <option value="file">Upload Video File</option>
            <option value="url">YouTube URL</option>
          </select>
        </div>
        <div class="hidden sm:block">
          <nav class="flex space-x-8" aria-label="Upload method">
            <button
              @click="uploadMethod = 'file'"
              x-bind:class="uploadMethod === 'file' ? 'border-wood-500 text-wood-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'"
              class="whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm"
            >
              <svg class="w-5 h-5 inline-block mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"/>
              </svg>
              Upload Video File
            </button>
            <button
              @click="uploadMethod = 'url'"
              x-bind:class="uploadMethod === 'url' ? 'border-wood-500 text-wood-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'"
              class="whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm"
            >
              <svg class="w-5 h-5 inline-block mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.1m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"/>
              </svg>
              YouTube URL
            </button>
          </nav>
        </div>
      </div>

      <.simple_form
        for={@form}
        id="video-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <!-- File Upload Section -->
        <div x-show="uploadMethod === 'file'" x-transition class="mb-6">
          <div class="form-group">
            <label class="form-label">Video File</label>
            
            <!-- File Upload Drop Zone -->
            <div
              x-data="fileUpload()"
              @drop="handleDrop($event)"
              @dragover.prevent
              @dragenter.prevent
              class="mt-1 flex justify-center px-6 pt-5 pb-6 border-2 border-gray-300 border-dashed rounded-md hover:border-wood-400 transition-colors"
              x-bind:class="{ 'border-wood-500 bg-wood-50': isDragging }"
              @dragenter="isDragging = true"
              @dragleave="isDragging = false"
              @drop="isDragging = false"
            >
              <div class="space-y-2 text-center">
                <svg class="mx-auto h-12 w-12 text-gray-400" stroke="currentColor" fill="none" viewBox="0 0 48 48">
                  <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                <div class="flex text-sm text-gray-600">
                  <label for="video-file-upload" class="relative cursor-pointer bg-white rounded-md font-medium text-wood-600 hover:text-wood-500 focus-within:outline-none focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-wood-500">
                    <span>Upload a video file</span>
                    <input 
                      id="video-file-upload" 
                      name="video-file-upload" 
                      type="file" 
                      accept="video/*"
                      class="sr-only" 
                      @change="handleFileSelect($event)"
                      phx-target={@myself}
                      phx-hook="FileUpload"
                    />
                  </label>
                  <p class="pl-1">or drag and drop</p>
                </div>
                <p class="text-xs text-gray-500">MP4, WebM, AVI, MOV up to 500MB</p>
                
                <!-- File Preview -->
                <div x-show="selectedFile" x-transition class="mt-4">
                  <div class="inline-flex items-center px-3 py-2 bg-wood-100 border border-wood-300 rounded-md">
                    <svg class="w-5 h-5 text-wood-600 mr-2" fill="currentColor" viewBox="0 0 20 20">
                      <path d="M2 6a2 2 0 012-2h5l2 2h5a2 2 0 012 2v6a2 2 0 01-2 2H4a2 2 0 01-2-2V6z"/>
                    </svg>
                    <span class="text-sm text-wood-900" x-text="selectedFile ? selectedFile.name : ''"></span>
                    <button 
                      @click="clearFile()" 
                      type="button" 
                      class="ml-2 text-wood-500 hover:text-wood-700"
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                      </svg>
                    </button>
                  </div>
                  
                  <!-- Upload Progress -->
                  <div x-show="uploadProgress > 0 && uploadProgress < 100" class="mt-2">
                    <div class="bg-gray-200 rounded-full h-2">
                      <div 
                        class="bg-wood-600 h-2 rounded-full transition-all duration-300"
                        x-bind:style="'width: ' + uploadProgress + '%'"
                      ></div>
                    </div>
                    <p class="text-xs text-gray-600 mt-1" x-text="'Uploading... ' + uploadProgress + '%'"></p>
                  </div>
                  
                  <!-- Upload Complete -->
                  <div x-show="uploadProgress === 100" class="mt-2 text-green-600 text-sm">
                    <svg class="w-4 h-4 inline mr-1" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                    </svg>
                    Upload complete!
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Thumbnail Upload -->
          <div class="form-group mt-6">
            <label class="form-label">Thumbnail (Optional)</label>
            <div class="mt-1 flex items-center space-x-4">
              <div class="w-32 h-24 bg-gray-100 border-2 border-dashed border-gray-300 rounded-lg flex items-center justify-center">
                <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                </svg>
              </div>
              <div>
                <button type="button" class="btn-secondary">
                  Choose Thumbnail
                </button>
                <p class="text-xs text-gray-500 mt-1">JPG, PNG up to 5MB</p>
              </div>
            </div>
          </div>
        </div>

        <!-- URL Section -->
        <div x-show="uploadMethod === 'url'" x-transition class="mb-6">
          <div class="form-group">
            <.input 
              field={@form[:url]} 
              type="url" 
              label="YouTube URL" 
              class="form-input"
              placeholder="https://youtube.com/watch?v=..."
            />
            <p class="mt-2 text-sm text-gray-600">
              We'll automatically extract the title, description, and thumbnail from YouTube.
            </p>
          </div>
        </div>

        <!-- Video Information -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
          <div class="form-group">
            <.input 
              field={@form[:title]} 
              type="text" 
              label="Title" 
              class="form-input"
              placeholder="Enter video title"
            />
          </div>
          
          <div class="form-group">
            <.input
              field={@form[:category_id]}
              type="select"
              label="Category"
              class="form-input"
              prompt="Choose a category"
              options={@categories}
            />
          </div>
        </div>

        <div class="form-group mb-6">
          <.input 
            field={@form[:description]} 
            type="textarea" 
            label="Description" 
            class="form-input"
            placeholder="Describe your video content, techniques, or materials used..."
            rows="4"
          />
        </div>

        <!-- Processing Status (for existing videos) -->
        <div :if={@video.id} class="mb-6 p-4 bg-gray-50 rounded-lg border border-gray-200">
          <h4 class="text-sm font-medium text-gray-900 mb-2">Processing Status</h4>
          <div class="flex items-center">
            <div class={"w-3 h-3 rounded-full mr-3 #{status_color(@video.processing_status)}"}>
            </div>
            <span class="text-sm text-gray-700 capitalize"><%= @video.processing_status || "pending" %></span>
          </div>
        </div>

        <:actions>
          <div class="flex items-center justify-between">
            <button
              type="button"
              phx-click={JS.patch(@patch)}
              class="btn-secondary"
            >
              Cancel
            </button>
            <.button phx-disable-with="Saving..." class="btn-primary">
              <%= if @video.id, do: "Update Video", else: "Create Video" %>
            </.button>
          </div>
        </:actions>
      </.simple_form>
    </div>

    <!-- Alpine.js File Upload Component -->
    <script>
      function fileUpload() {
        return {
          isDragging: false,
          selectedFile: null,
          uploadProgress: 0,
          
          handleDrop(e) {
            e.preventDefault();
            const files = e.dataTransfer.files;
            if (files.length > 0) {
              this.handleFile(files[0]);
            }
          },
          
          handleFileSelect(e) {
            const files = e.target.files;
            if (files.length > 0) {
              this.handleFile(files[0]);
            }
          },
          
          handleFile(file) {
            // Validate file type
            const allowedTypes = ['video/mp4', 'video/webm', 'video/avi', 'video/mov', 'video/quicktime'];
            if (!allowedTypes.includes(file.type)) {
              alert('Please select a valid video file (MP4, WebM, AVI, MOV)');
              return;
            }
            
            // Validate file size (500MB)
            if (file.size > 500 * 1024 * 1024) {
              alert('File size must be less than 500MB');
              return;
            }
            
            this.selectedFile = file;
            this.simulateUpload();
          },
          
          clearFile() {
            this.selectedFile = null;
            this.uploadProgress = 0;
            document.getElementById('video-file-upload').value = '';
          },
          
          simulateUpload() {
            // Simulate upload progress
            this.uploadProgress = 0;
            const interval = setInterval(() => {
              this.uploadProgress += Math.random() * 30;
              if (this.uploadProgress >= 100) {
                this.uploadProgress = 100;
                clearInterval(interval);
              }
            }, 200);
          }
        }
      }
    </script>
    """
  end

  defp status_color("completed"), do: "bg-green-500"
  defp status_color("processing"), do: "bg-yellow-500"
  defp status_color("failed"), do: "bg-red-500"
  defp status_color(_), do: "bg-gray-400"

    @impl true
  def update(%{video: video} = assigns, socket) do
    changeset = Multimedia.change_video(video)
    categories = Multimedia.list_alphabetical_categories()
    category_options = for category <- categories, do: {category.name, category.id}

    socket =
      socket
      |> assign(assigns)
      |> assign(:form, to_form(changeset))
      |> assign(:categories, category_options)
      |> allow_upload(:video, 
          accept: ~w(.mp4 .webm .avi .mov),
          max_entries: 1,
          max_file_size: 500_000_000, # 500MB
          progress: &handle_progress/3,
          auto_upload: true
        )
      |> allow_upload(:thumbnail,
          accept: ~w(.jpg .jpeg .png),
          max_entries: 1,
          max_file_size: 5_000_000, # 5MB
          progress: &handle_progress/3
        )

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"video" => video_params}, socket) do
    changeset = Rumbl.Multimedia.Video.changeset(socket.assigns.video, video_params)
    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"video" => video_params}, socket) do
    # Handle file uploads if present
    video_params = 
      video_params
      |> maybe_process_video_upload(socket)
      |> maybe_process_thumbnail_upload(socket)
    
    save_video(socket, socket.assigns.action, video_params)
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :video, ref)}
  end

  def handle_event("cancel-thumbnail-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :thumbnail, ref)}
  end

  # Handle upload progress
  defp handle_progress(:video, entry, socket) do
    if entry.done? do
      # Video upload completed, we could trigger processing here
      # For now, we'll handle it in the save process
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  defp handle_progress(:thumbnail, entry, socket) do
    if entry.done? do
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  # Process video file upload
  defp maybe_process_video_upload(video_params, socket) do
    case uploaded_entries(socket, :video) do
      [entry | _] ->
        # Consume the upload and save file
        [file_path] = consume_uploaded_entries(socket, :video, fn %{path: path}, entry ->
          dest_path = generate_file_path(entry.client_name, "videos")
          File.mkdir_p!(Path.dirname(dest_path))
          File.cp!(path, dest_path)
          dest_path
        end)

        video_params
        |> Map.put("video_file_path", file_path)
        |> Map.put("video_file_size", entry.client_size)
        |> Map.put("video_file_type", entry.client_type)
        |> Map.put("original_filename", entry.client_name)
        |> Map.put("processing_status", "processing")
        |> Map.put("storage_provider", "local")

      [] ->
        video_params
    end
  end

  # Process thumbnail upload
  defp maybe_process_thumbnail_upload(video_params, socket) do
    case uploaded_entries(socket, :thumbnail) do
      [entry | _] ->
        [file_path] = consume_uploaded_entries(socket, :thumbnail, fn %{path: path}, entry ->
          dest_path = generate_file_path(entry.client_name, "thumbnails")
          File.mkdir_p!(Path.dirname(dest_path))
          File.cp!(path, dest_path)
          dest_path
        end)

        video_params
        |> Map.put("thumbnail_path", file_path)
        |> Map.put("thumbnail_size", entry.client_size)
        |> Map.put("thumbnail_type", entry.client_type)

      [] ->
        video_params
    end
  end

  # Generate unique file path
  defp generate_file_path(original_filename, type) do
    ext = Path.extname(original_filename)
    filename = "#{Ecto.UUID.generate()}#{ext}"
    Path.join(["priv", "static", "uploads", type, filename])
  end

  defp save_video(socket, :edit, video_params) do
    case Multimedia.update_video(socket.assigns.video, video_params) do
      {:ok, video} ->
        # Start processing if a new video file was uploaded
        maybe_start_processing(video)
        
        # Broadcast update for real-time functionality
        Phoenix.PubSub.broadcast!(Rumbl.PubSub, "videos", {:video_updated, video})

        notify_parent({:saved, video})

        {:noreply,
         socket
         |> put_flash(:info, "Video updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_video(socket, :new, video_params) do
    case Multimedia.create_video(socket.assigns.current_user, video_params) do
      {:ok, video} ->
        # Start processing if a video file was uploaded
        maybe_start_processing(video)
        
        # Broadcast creation for real-time functionality
        Phoenix.PubSub.broadcast!(Rumbl.PubSub, "videos", {:video_created, video})

        notify_parent({:saved, video})

        {:noreply,
         socket
         |> put_flash(:info, "Video created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  # Start video processing in the background if needed
  defp maybe_start_processing(%{processing_status: "processing"} = video) do
    # In production, you'd use a proper job queue like Oban
    Task.start(fn ->
      Rumbl.Multimedia.VideoProcessor.process_video(video.id)
    end)
  end

  defp maybe_start_processing(_video), do: :ok

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end