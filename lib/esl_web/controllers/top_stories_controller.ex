defmodule EslWeb.TopStoriesController do
    alias Esl.TopStories.Worker
    use EslWeb, :controller

    def index(conn, _params) do
        render(conn, "index.html")
    end

    @spec list(Plug.Conn.t(), any) :: Plug.Conn.t()
    def list(conn, %{"page_number" => page_number} = params) do
        with {:ok, version} <- get_version(Map.get(params, "version")),
          {:ok, page_number} <- to_positive_number(page_number),
          {:ok, page_size} <- to_positive_number(Map.get(params, "page_size", "10")) do
          
          render(conn, "list.json", %{top_stories: get_top_stories(version, page_number, page_size)})
        else
          _ ->
            render(conn, "list.json", %{top_stories: %{error: "invalid query parameter, positive number is expected"}})
        end
    end
  
    def list(conn, _params) do
      page_size = 10
      render(conn, "list.json", %{top_stories: get_top_stories(nil, 0, page_size)})
    end
  
    @spec detail(Plug.Conn.t(), map) :: Plug.Conn.t()
    def detail(conn, %{"id" => id}) do
      case to_positive_number(id) do
        {:ok, id} ->
          render(conn, "detail.json", %{detail: get_detail(id)})
        _ ->
          render(conn, "detail.json", %{detail: %{error: "invalid id"}})
      end
    end
    
    ######################################################################################
    ## Private Function
    #####################################################################################
    defp get_top_stories(version, page_number, page_size) do
      case Worker.retrieve_data(version, page_number, page_size) do
        {:ok, version, top_stories} -> %{version: version, top_stories: top_stories}
        {:error, msg} -> %{error: msg}
      end
    end
  
    defp to_positive_number(s) do
      s
      |> Integer.parse()
      |> case do
        {n, ""} when n >= 0 -> {:ok, n}
        _ -> :error
      end
    end
  
    defp get_version(nil) do
      {:ok, nil}
    end
  
    defp get_version(version) do
      to_positive_number(version)
    end
  
    defp get_detail(id) do
      case Worker.retrieve_detail(id) do
        {:ok, story_detail} -> %{detail: story_detail}
        {:error, msg} -> %{error: msg}
      end
    end
  
  end
  
  