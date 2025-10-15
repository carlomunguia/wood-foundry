defmodule Rumbl.TestHelpers do
  alias Rumbl.{
    Accounts,
    Multimedia
    }

  def user_fixture(attrs \\ %{}) do
    unique_id = System.unique_integer([:positive])
    {:ok, user} =
      attrs
      |> Enum.into(
           %{
             name: "Some User",
             username: attrs[:username] || "user#{unique_id}",
             email: "user#{unique_id}@example.com",
             password: attrs[:password] || "supersecret"
           }
         )
      |> Accounts.register_user()
    user
  end

  def video_fixture(%Accounts.User{} = user, attrs \\ %{}) do
    attrs =
      Enum.into(
        attrs,
        %{
          title: "A title",
          url: "http://example.com",
          description: "a description"
        }
      )
    {:ok, video} = Multimedia.create_video(user, attrs)
    video
  end
end
