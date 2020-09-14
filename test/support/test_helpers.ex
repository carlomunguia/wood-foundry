defmodule Rumbl.TestHelpers do
  alias Rumbl.{
    Accounts,
    Multimedia
    }

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(
           %{
             name: "Some User",
             username: "user#{System.unique_integer([:positive])}",
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
