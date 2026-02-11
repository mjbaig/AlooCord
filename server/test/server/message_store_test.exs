defmodule Server.MessageStoreTest do
  alias Server.MessageStore
  use ExUnit.Case, async: false

  alias Server.Impl.MessageStore

  setup do
    MessageStore.reset()
    :ok
  end

  test "stores a message and assigns sequential ids" do
    message1 =
      MessageStore.store_message(%{
        "accountId" => 1,
        "content" => "hello"
      })

    message2 =
      MessageStore.store_message(%{
        "accountId" => 2,
        "content" => "world"
      })

    assert message1.id == 1
    assert message2.id == 2
  end

  test "get_all_messages returns stored messages" do
    MessageStore.store_message(%{"accountId" => 1, "content" => "a"})
    MessageStore.store_message(%{"accountId" => 2, "content" => "b"})

    messages = MessageStore.get_all_messages()

    assert length(messages) == 2
    assert Enum.at(messages, 0).content == "a"
    assert Enum.at(messages, 1).content == "b"
  end

  test "get_messages_after returns only newer messages" do
    MessageStore.store_message(%{"accountId" => 1, "content" => "a"})
    MessageStore.store_message(%{"accountId" => 1, "content" => "b"})
    MessageStore.store_message(%{"accountId" => 1, "content" => "c"})

    messages = MessageStore.get_messages_after(1)

    assert length(messages) == 2
    assert Enum.map(messages, & &1.content) == ["b", "c"]
  end
end
