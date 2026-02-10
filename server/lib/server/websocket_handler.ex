defmodule Server.WebsocketHandler do
  def init(_args) do
    {:ok, %{client_id: make_ref()}}
  end

  def handle_in({msg, _opts}, state) do
    case Jason.decode(msg) do
      {:ok, data} ->
        Server.MessageStore.store_message(data)
        Server.ClientRegistry.broadcast(data)

      _ ->
        :ok
    end

    {:ok, state}
  end

  def handle_info({:broadcast, data}, state) do
    {:push, {:text, Jason.encode!(data)}, state}
  end

  def handle_connect(_conn, state) do
    Server.ClientRegistry.register(self())

    # Send all stored messages to new client

    Server.MessageStore.get_messages()
    |> Enum.each(fn message ->
      send(self(), {:broadcast, message})
    end)

    {:ok, state}
  end

  def handle_disconnect(_reason, state) do
    Server.ClientRegistry.unregister(self())
    {:ok, state}
  end
end
