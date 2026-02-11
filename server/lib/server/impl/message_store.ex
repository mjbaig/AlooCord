# Caches most recent messages to memeory
# Loads history at start up
defmodule Server.Impl.MessageStore do
  use GenServer

  @max_messages 1000

  # api
  def start_link(_) do
    GenServer.start_link(
      __MODULE__,
      %{
        messages: [],
        nextId: 1
      },
      name: __MODULE__
    )
  end

  def reset do
    GenServer.call(__MODULE__, :reset)
  end

  def store_message(%{"accountId" => accountId, "content" => content}) do
    GenServer.call(__MODULE__, {:store, accountId, content})
  end

  def get_all_messages do
    GenServer.call(__MODULE__, :all)
  end

  def get_messages_after(id) do
    GenServer.call(__MODULE__, {:after, id})
  end

  # callbacks

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:store, accountId, content}, _from, state) do
    message = %{
      id: state.nextId,
      accountId: accountId,
      content: content,
      insertedAt: DateTime.utc_now()
    }

    newState = %{
      state
      | messages:
          (state.messages ++ [message])
          |> Enum.take(-@max_messages),
        nextId: state.nextId + 1
    }

    {:reply, message, newState}
  end

  @impl true
  def handle_call({:after, id}, _from, state) do
    messages =
      state.messages
      |> Enum.filter(fn m -> m.id > id end)

    {:reply, messages, state}
  end

  def handle_call(:all, _from, state) do
    {:reply, state.messages, state}
  end

  def handle_call(:reset, _from, _state) do
    {:reply, :ok, %{messages: [], nextId: 1}}
  end
end
