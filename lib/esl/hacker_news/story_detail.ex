defmodule Esl.HackerNews.StoryDetail do
    
    @spec fetch_item(number) :: {:error, String.t | Jason.DecodeError.t()} | {:ok, any}
    def fetch_item(id) do
      url = "https://hacker-news.firebaseio.com/v0/item/#{id}.json?print=pretty"
      response = HTTPoison.get!(url)
      case response.status_code do
        200 -> Jason.decode(response.body)
        http_code -> {:error, "Bad response with http code: #{http_code}"}
      end
      
    end
  end