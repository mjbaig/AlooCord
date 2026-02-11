defmodule Server.WebsocketHandlerTest do
  use ExUnit.Case, async: false

  alias Server.WebsocketHandler
  alias Server.Impl.MessageStore

  setup do
    MessageStore.reset()
    :ok
  end

  test "handle_client_message stores and broadcasts" do
    state = %{accountId: 10}

    data = %{"content" => "hello"}

    {:ok, _state} =
      WebsocketHandler.handle_client_message(data, state)

    messages = MessageStore.get_all_messages()

    assert length(messages) == 1

    stored = hd(messages)

    assert stored.accountId == 10
    assert stored.content == "hello"
  end

  test "send_unseen_messages only sends newer ones" do
    MessageStore.store_message(%{"accountId" => 1, "content" => "a"})
    MessageStore.store_message(%{"accountId" => 1, "content" => "b"})

    _parent = self()

    # simulate the send function
    WebsocketHandler.send_unseen_messages(1)

    assert_receive {:broadcast, %{content: "b"}}
  end
end
