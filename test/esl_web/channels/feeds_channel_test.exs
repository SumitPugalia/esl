defmodule EslWeb.FeedsChannelTest do
  use EslWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      socket(EslWeb.UserSocket, "user_id", %{some: :assign})
      |> subscribe_and_join(EslWeb.FeedsChannel, "feeds")

    {:ok, socket: socket}
  end
end
