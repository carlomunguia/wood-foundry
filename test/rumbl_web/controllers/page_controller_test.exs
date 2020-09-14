defmodule RumblWeb.PageControllerTest do
  use RumblWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to the Pink Ivory Foundry!!"
  end
end
