defmodule EslWeb.TopStoriesView do
    use EslWeb, :view
    
    def render("list.json", %{top_stories: top_stories}) do
      %{data: top_stories}
    end
  
    def render("detail.json", %{detail: detail}) do
      %{data: detail}
    end
  end
  