defmodule Esl.HackerNews.Supervisor do
    @moduledoc false
    use Supervisor
    alias Esl.HackerNews

    @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
    def start_link(_) do
      Supervisor.start_link(__MODULE__, [], name: __MODULE__)
    end
  
    @impl true
    @spec init(any) :: {:ok, {%{intensity: any, period: any, strategy: any}, [any]}}
    def init(_) do
      children = [
        ## can use child spec map
        HackerNews.Worker,
        {Task.Supervisor,
          name: StoryDetailTaskSupervisor,
          restart: :permanent
        }
      ]
  
      Supervisor.init(children, strategy: :one_for_one)
    end
end