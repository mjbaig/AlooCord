defmodule ClientRegistryTest do
  use ExUnit.Case, async: false

  alias Server.Impl.ClientRegistry

  setup do
    ClientRegistry.reset()
    :ok
  end

  defp spawn_listener(parent) do
    spawn(fn ->
      receive do
        {:broadcast, data} ->
          send(parent, {:received, self(), data})
      after
        200 ->
          send(parent, {:timeout, self()})
      end
    end)
  end

  test "register and unregister clients" do
    pid = self()

    accountId = "account1"

    ClientRegistry.register(accountId, pid)

    accounts = ClientRegistry.list_accounts()

    assert accounts == [accountId]
  end

  test "registering multiple pids for the same account" do
    pid1 = spawn(fn -> :timer.sleep(:infinity) end)
    pid2 = spawn(fn -> :timer.sleep(:infinity) end)

    ClientRegistry.register("accountId1", pid1)
    ClientRegistry.register("accountId1", pid2)

    pids = ClientRegistry.get_pids("accountId1")

    assert MapSet.member?(pids, pid1)

    assert MapSet.member?(pids, pid2)
  end

  test "broadcast_to_user only reaches that user's pids" do
    parent = self()

    pid1 = spawn_listener(parent)
    pid2 = spawn_listener(parent)
    other = spawn_listener(parent)

    ClientRegistry.register("alice", pid1)
    ClientRegistry.register("alice", pid2)
    ClientRegistry.register("sanders", other)

    ClientRegistry.broadcast_to_user("alice", %{message: "hello"})

    assert_receive {:received, ^pid1, %{message: "hello"}}
    assert_receive {:received, ^pid2, %{message: "hello"}}

    refute_receive {:received, ^other}
  end

  test "unregister removes a pid from an account" do
    pid = spawn(fn -> :timer.sleep(:infinity) end)

    ClientRegistry.register("account1", pid)

    assert MapSet.member?(ClientRegistry.get_pids("account1"), pid)

    ClientRegistry.unregister("account1", pid)

    refute MapSet.member?(ClientRegistry.get_pids("account1"), pid)
  end

  test "process DOWN message automatically cleans up registry" do
    dyingPid = spawn(fn -> :ok end)

    ClientRegistry.register("accountId", dyingPid)

    :timer.sleep(50)

    pids = ClientRegistry.get_pids("accountId")

    assert MapSet.size(pids) == 0
  end

  test "reset clear registry state" do
    pid = spawn(fn -> :timer.sleep(:infinity) end)

    ClientRegistry.register("accountId", pid)

    assert ClientRegistry.list_accounts() == ["accountId"]

    ClientRegistry.reset()

    assert ClientRegistry.list_accounts() == []
  end
end
