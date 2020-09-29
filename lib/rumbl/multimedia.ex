defmodule Rumbl.Multimedia do
  import Ecto.Query, warn: false

  alias Rumbl.Repo
  alias Rumbl.Multimedia.{Video, Category}
  alias Rumbl.Accounts

  def list_videos do
    Repo.all(Video)
  end

  def create_category!(name) do
    Repo.insert!(%Category{name: name}, on_conflict: :nothing)
  end

  def list_alphabetical_categories do
    Category
    |> Category.alphabetical()
    |> Repo.all()
  end

  def list_user_videos(%Accounts.User{} = user) do
    Video
    |> user_videos_query(user)
    |> Repo.all()
  end

  def get_user_video!(%Accounts.User{} = user, id) do
    Video
    |> user_videos_query(user)
    |> Repo.get!(id)
  end

  def get_video!(id), do: Repo.get!(Video, id)

  defp user_videos_query(query, %Accounts.User{id: user_id}) do
    from(v in query, where: v.user_id == ^user_id)
  end

  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
  end

  def delete_video(%Video{} = video) do
    Repo.delete(video)
  end

  def create_video(%Accounts.User{} = user, attrs \\ %{}) do
    %Video{}
    |> Video.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  def change_video(%Video{} = video) do
    Video.changeset(video, %{})
  end

  alias Rumbl.Multimedia.Annotation

  def annotate_video(%Accounts.User{id: user_id}, video_id, attrs) do
    %Annotation{video_id: video_id, user_id: user_id}
    |> Annotation.changeset(attrs)
    |> Repo.insert()
  end

  def list_annotations(%Video{} = video) do
    Repo.all(
      from a in Ecto.assoc(video, :annotations),
      order_by: [asc: a.at, asc: a.id],
      limit: 500,
      preload: [:user]
    )
  end
end
