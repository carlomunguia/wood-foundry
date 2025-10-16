defmodule Rumbl.VideoControllerTest do
  use RumblWeb.ConnCase, async: true

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, ~p"/manage/videos/new"),
        get(conn, ~p"/manage/videos"),
        get(conn, ~p"/manage/videos/123"),
        get(conn, ~p"/manage/videos/123/edit"),
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end

  describe "with a logged in user" do
    setup %{conn: conn} do
      user = user_fixture(username: "kiryukazama")
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    test "list all user's videos on index", %{conn: conn, user: user} do
      user_video = video_fixture(user, title: "funny cats")
      other_video = video_fixture(
        user_fixture(username: "other"),
        title: "another video"
      )
      conn = get conn, ~p"/manage/videos"
      assert html_response(conn, 200) =~ "Videos"
      assert String.contains?(conn.resp_body, user_video.title)
      refute String.contains?(conn.resp_body, other_video.title)
    end

    alias Rumbl.Multimedia

    @create_attrs %{
      url: "http://youtu.be",
      title: :vid,
      description: "a vid"
    }
    @invalid_attrs %{title: "invalid"}

    defp video_count, do: Enum.count(Multimedia.list_videos())

    @tag :skip
    test "create user video and redirects", %{conn: conn, user: user} do
      # This functionality is now handled by LiveView components
      # See test/rumbl_web/live/video_live_test.exs for video tests
    end

    @tag :skip
    test "does not create vid, renders errors when invalid", %{conn: conn} do
      # This functionality is now handled by LiveView components
      # See test/rumbl_web/live/video_live_test.exs for video tests
    end

    @tag :skip
    test "authorizes actions against access by other users", %{conn: conn} do
      # This functionality is now handled by LiveView components
      # See test/rumbl_web/live/video_live_test.exs for video tests
    end
  end
end
