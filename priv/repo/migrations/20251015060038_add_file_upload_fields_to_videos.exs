defmodule Rumbl.Repo.Migrations.AddFileUploadFieldsToVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      # File upload fields
      add :video_file_path, :string          # Path to uploaded video file
      add :video_file_size, :bigint          # File size in bytes
      add :video_file_type, :string          # MIME type (video/mp4, etc.)
      add :video_duration, :integer          # Video duration in seconds
      
      # Thumbnail/cover image fields
      add :thumbnail_path, :string           # Path to thumbnail image
      add :thumbnail_size, :bigint          # Thumbnail file size
      add :thumbnail_type, :string          # Image MIME type
      
      # Processing status
      add :processing_status, :string, default: "pending"  # pending, processing, completed, failed
      add :upload_completed_at, :utc_datetime
      
      # Original filename for reference
      add :original_filename, :string
      
      # Cloud storage fields (for future S3/Cloudflare integration)
      add :storage_provider, :string, default: "local"  # local, s3, cloudflare
      add :storage_key, :string              # Storage key/path in cloud provider
      add :cdn_url, :string                  # CDN URL for optimized delivery
    end

    # Index for efficient queries
    create index(:videos, [:processing_status])
    create index(:videos, [:storage_provider])
    create index(:videos, [:upload_completed_at])
  end
end
