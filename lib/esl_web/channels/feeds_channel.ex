defmodule EslWeb.FeedsChannel do
  use EslWeb, :channel
  alias Esl.TopStories.Worker

  def join("feeds", _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    case Worker.retrieve_data(nil, 0, 50) do
      {:ok, _, top_stories} -> 
        push(socket, "new_feed", %{data: top_stories})
      {:error, msg} -> 
        %{error: msg}
    end
    
    {:noreply, socket}
  end

  def broadcast_feed(feed) do
    EslWeb.Endpoint.broadcast("feeds", "new_feed", %{data: feed})
  end
end
