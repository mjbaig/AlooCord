defmodule Server.ClientRegistry do
  use GenServer

  # api

  def start_link(_) do
    GenServer.start_link(__MODULE__, MapSet.new(), name: __MODULE__)
  end

  def register(pid) do
    GenServer.cast(__MODULE__, {:register, pid})
  end

  def unregister(pid) do
    GenServer.cast(__MODULE__, {:unregister, pid})
  end

  def broadcast(message) do
    GenServer.cast(__MODULE__, {:broadcast, message})
  end

  ## callbacks
  def init(state) do
    {:ok, state}
  end

  def handle_cast({:register, pid}, state) do
    {:noreply, MapSet.put(state, pid)}
  end

  def handle_cast({:unregister, pid}, state) do
    {:noreply, MapSet.delete(state, pid)}
  end

  def handle_cast({:broadcast, message}, state) do
    Enum.each(state, fn pid ->
      send(pid, {:broadcast, message})
    end)

    {:noreply, state}
  end
end
