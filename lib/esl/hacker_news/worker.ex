defmodule Esl.HackerNews.Worker do
    use GenServer
    @moduledoc false
    
    @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
    def start_link(opts) do
      GenServer.start_link(__MODULE__, opts, name: __MODULE__)
    end
    
    @spec fetch :: {:error, String.t} | {:ok, list(map)}
    def fetch() do
        GenServer.call(__MODULE__, :fetch_top_stories)
    end

    @impl true
    @spec init(any) :: {:ok, %{}}
    def init(_) do
      {:ok, %{}}
    end
    
    @impl true
    def handle_call(:fetch_top_stories, _from, state) do
        url = "https://hacker-news.firebaseio.com/v0/topstories.json"
        response = HTTPoison.get!(url)
        reply = 
            case response.status_code do
                200 ->
                    case Jason.decode(response.body) do
                        {:ok, data} ->
                            data
                            |> Enum.slice(0, 50)
                            |> fetch_story_details()

                        {:error, error} ->
                            {:error, error}
                    end
                
                http_code -> 
                    {:error, "Bad response with http code: #{http_code}"}
            end

        {:reply, reply, state}
    end

    defp fetch_story_details(top_stories_id) do
        top_stories =
            top_stories_id
            |> Enum.map(fn id -> Task.Supervisor.async(StoryDetailTaskSupervisor,  Esl.HackerNews.StoryDetail, :fetch_item, [id]) end)
            |> Task.yield_many()
            |> Enum.reduce([], fn {task, result}, acc ->
                case result do
                    nil ->
                        Task.shutdown(task, :brutal_kill)
                        exit(:timeout)
                        acc
                    {:exit, reason} ->
                        exit(reason)
                        acc
                    
                    {:ok, {:ok, result}} ->
                        [result | acc]
                    _ ->
                        acc
                end
            end)
            
        {:ok, top_stories}
    end
end