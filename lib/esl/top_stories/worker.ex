defmodule Esl.TopStories.Worker do
    use GenServer
    @moduledoc false
    
    alias Esl.HackerNews
    
    @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
    def start_link(opts) do
      GenServer.start_link(__MODULE__, opts, name: __MODULE__)
    end
    
    @spec retrieve_data(number, number, number) :: {:ok, number, list(map)} | {:error, String.t}
    def retrieve_data(id, page_number, page_size) do
        GenServer.call(__MODULE__, {:retrieve, id, page_number, page_size})
    end

    @spec retrieve_detail(number) :: {:error, String.t} | {:ok, map}
    def retrieve_detail(id) do
        %{versions: [latest, old], news: news} = GenServer.call(__MODULE__, :retrieve_state)
        
        Map.get(news, latest)
        |> Enum.concat(Map.get(news, old))
        |> Enum.find(fn item -> Map.get(item, "id")  == id end)
        |> case do
            nil ->
                {:error, "detail not found for id"}
            detail ->
                {:ok, detail}
        end
    end

    @impl true
    @spec init(any) ::
            {:error, any} | {:ok, %{news: %{optional(integer) => []}, versions: [integer, ...]}}
    def init(_) do
      poll_period = Application.get_env(:esl, :poll_period)[:hacker_news]
      
      # initial message to fetch_data
      Process.send(self(), :fetch_data, [])
      
      # sending the fetch_data message every poll_period seconds
      case :timer.send_interval(poll_period * 1_000, :fetch_data) do
        {:ok, _tref} ->

            old = System.system_time(:millisecond)
            #  to have different values for versions 
            latest = System.system_time(:millisecond) + 1
            
            news = %{old => [], latest => []}
            {:ok, %{versions: [latest, old], news: news}}
        
        {:error, error} -> 
            IO.inspect(error)
            {:error, error}
      end
    end
    
    @impl true
    def handle_call({:retrieve, id, page_number, page_size}, _from, %{versions: [latest, _old], news: news} = state) do
        id = if is_nil(id), do: latest, else: id

        response = 
            case Map.get(news, id) do
                nil -> {:error, "version is too old to fetch data, try the latest version"}
                data ->
                    top_news = 
                        data 
                        |> Enum.chunk_every(page_size) 
                        |> Enum.at(page_number)
                    
                    case top_news do
                        nil -> {:error, "no data found for this page number"}
                        top_news -> {:ok, id, top_news} 
                    end 
            end

        {:reply, response, state}
    end

    def handle_call(:retrieve_state, _from, state) do
        {:reply, state, state}
    end

    @impl true
    def handle_info(:fetch_data, state) do
        spawn(fn -> 
            case HackerNews.Worker.fetch() do
                {:ok, data} ->
                    Process.send(__MODULE__, {:update_data, data}, [])
                {:error, error} ->
                    IO.inspect(error)
                    state
            end
        end)

      {:noreply, state}
    end

    def handle_info({:update_data, data}, %{versions: [latest, old], news: news}) do
        new = System.system_time(:millisecond)
        new_versions = [new, latest]
        news = news |> Map.delete(old) |> Map.put(new, data)

        EslWeb.FeedsChannel.broadcast_feed(data)
        {:noreply, %{versions: new_versions, news: news}}
    end

    def handle_info(_, state) do
        {:noreply, state}
    end
end