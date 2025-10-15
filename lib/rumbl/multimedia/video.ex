defmodule Rumbl.Multimedia.Video do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Rumbl.Multimedia.Permalink, autogenerate: true}
  schema "videos" do
    # Basic video info
    field :description, :string
    field :title, :string
    field :url, :string
    field :slug, :string

    # File upload fields
    field :video_file_path, :string
    field :video_file_size, :integer
    field :video_file_type, :string
    field :video_duration, :integer
    
    # Thumbnail fields
    field :thumbnail_path, :string
    field :thumbnail_size, :integer
    field :thumbnail_type, :string
    
    # Processing and metadata
    field :processing_status, :string, default: "pending"
    field :upload_completed_at, :utc_datetime
    field :original_filename, :string
    
    # Cloud storage fields
    field :storage_provider, :string, default: "local"
    field :storage_key, :string
    field :cdn_url, :string

    belongs_to :user, Rumbl.Accounts.User
    belongs_to :category, Rumbl.Multimedia.Category

    has_many :annotations, Rumbl.Multimedia.Annotation

    timestamps()
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:url, :title, :description, :category_id])
    |> validate_required([:title, :description])
    |> validate_url_or_file()
    |> assoc_constraint(:category)
    |> slugify_title()
  end

  @doc false
  def upload_changeset(video, attrs) do
    video
    |> cast(attrs, [
      :title, :description, :category_id,
      :video_file_path, :video_file_size, :video_file_type, :video_duration,
      :thumbnail_path, :thumbnail_size, :thumbnail_type,
      :processing_status, :upload_completed_at, :original_filename,
      :storage_provider, :storage_key, :cdn_url
    ])
    |> validate_required([:title, :description])
    |> validate_file_fields()
    |> assoc_constraint(:category)
    |> slugify_title()
  end

  defp validate_url_or_file(changeset) do
    url = get_field(changeset, :url)
    video_file_path = get_field(changeset, :video_file_path)
    
    cond do
      url && String.trim(url) != "" -> changeset
      video_file_path && String.trim(video_file_path) != "" -> changeset
      true -> add_error(changeset, :base, "Must provide either a video URL or upload a video file")
    end
  end

  defp validate_file_fields(changeset) do
    changeset
    |> validate_file_size()
    |> validate_file_type()
  end

  defp validate_file_size(changeset) do
    case get_field(changeset, :video_file_size) do
      size when is_integer(size) and size > 500_000_000 -> # 500MB limit
        add_error(changeset, :video_file_size, "File size must be less than 500MB")
      _ ->
        changeset
    end
  end

  defp validate_file_type(changeset) do
    allowed_types = ["video/mp4", "video/webm", "video/avi", "video/mov", "video/quicktime"]
    
    case get_field(changeset, :video_file_type) do
      type when is_binary(type) ->
        if type in allowed_types do
          changeset
        else
          add_error(changeset, :video_file_type, "File type must be mp4, webm, avi, or mov")
        end
      _ ->
        changeset
    end
  end

  defp slugify_title(changeset) do
    case fetch_change(changeset, :title) do
      {:ok, new_title} -> put_change(changeset, :slug, slugify(new_title))
      :error -> changeset
    end
  end

  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
  end
end
