# Long lived process that keeps track of which websocket clients are connected.
# using the process ids. It uses the process ids to broadcast to their sockets.
# TODO tie this to an account id
defmodule Server.Impl.ClientRegistry do
  use GenServer

  # api

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def register(accountId, pid) do
    GenServer.cast(__MODULE__, {:register, accountId, pid})
  end

  def unregister(accountId, pid) do
    GenServer.cast(__MODULE__, {:unregister, accountId, pid})
  end

  def get_pids(accountId) do
    GenServer.call(__MODULE__, {:get_pids, accountId})
  end

  def reset do
    GenServer.call(__MODULE__, :reset)
  end

  def broadcast_to_user(accountId, message) do
    GenServer.cast(__MODULE__, {:broadcast_user, accountId, message})
  end

  def broadcast_global(message) do
    GenServer.cast(__MODULE__, {:broadcast_all, message})
  end

  def list_accounts() do
    GenServer.call(__MODULE__, :list)
  end

  ## callbacks
  @impl true
  def init(state) do
    {:ok, state}
  end

  def handle_call(:reset, _from, _state) do
    {:reply, :ok, %{}}
  end

  @impl true
  def handle_call(:list, _from, state) do
    {:reply, Map.keys(state), state}
  end

  def handle_call({:get_pids, accountId}, _from, state) do
    {:reply, Map.get(state, accountId, MapSet.new()), state}
  end

  @impl true
  def handle_cast({:register, accountId, pid}, state) do
    Process.monitor(pid)

    newState =
      Map.update(state, accountId, MapSet.new([pid]), fn set ->
        MapSet.put(set, pid)
      end)

    {:noreply, newState}
  end

  def handle_cast({:unregister, accountId, pid}, state) do
    newState =
      Map.update(state, accountId, MapSet.new(), fn set ->
        MapSet.delete(set, pid)
      end)

    {:noreply, newState}
  end

  def handle_cast({:broadcast_user, accountId, message}, state) do
    state
    |> Map.get(accountId, MapSet.new())
    |> Enum.each(fn pid ->
      send(pid, {:broadcast, message})
    end)

    {:noreply, state}
  end

  def handle_cast({:broadcast_all, message}, state) do
    state
    |> Map.values()
    |> Enum.flat_map(&MapSet.to_list/1)
    |> Enum.each(fn pid ->
      send(pid, {:broadcast, message})
    end)

    {:noreply, state}
  end

  # Cleanup
  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _}, state) do
    newState =
      Enum.reduce(state, %{}, fn {accountId, pids}, acc ->
        Map.put(acc, accountId, MapSet.delete(pids, pid))
      end)

    {:noreply, newState}
  end
end
