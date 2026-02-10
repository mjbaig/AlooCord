defmodule Server.MessageStore do
  use GenServer

  @max_messages 1000

  # api
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def store_message(message) do
    GenServer.cast(__MODULE__, {:store, message})
  end

  def get_messages do
    GenServer.call(__MODULE__, :get)
  end

  # callbacks

  def init(_) do
    {:ok, []}
  end

  def handle_cast({:store, message}, state) do
    new_state =
      [message | state]
      |> Enum.take(@max_messages)

    {:noreply, new_state}
  end

  def handle_call(:get, _from, state) do
    {:reply, Enum.reverse(state), state}
  end
end
