defmodule RumblWeb.VideoView do
  use RumblWeb, :view

  def category_select_options(categories) do
    for category <- categories, do: {category.name, category.id}
  end

  def video_view_count(_video) do
    # For now, return a simple view count
    # In the future, this could connect to analytics or a view tracking system
    "0 views"
  end
end
