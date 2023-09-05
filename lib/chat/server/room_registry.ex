defmodule Chat.Server.RoomRegistry do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(initial_state) do
    {:ok, initial_state}
  end

  def list_rooms() do
    GenServer.call(__MODULE__, :list_rooms)
  end

  def join_room(client_socket, room_name) do
    GenServer.call(__MODULE__, {:join_room, client_socket, room_name})
  end

  def leave_room(client_socket, room_name) do
    GenServer.call(__MODULE__, {:leave_room, client_socket, room_name})
  end

  def get_participants(room_name) do
    GenServer.call(__MODULE__, {:get_participants, room_name})
  end

  def handle_call(:list_rooms, _from, state) do
    {:reply, Map.keys(state), state}
  end

  def handle_call({:join_room, client_socket, room_name}, _from, state) do
    room_participants = Map.get(state, room_name, MapSet.new())

    updated_participants = MapSet.put(room_participants, client_socket)

    {:reply, :ok, Map.put(state, room_name, updated_participants)}
  end

  def handle_call({:leave_room, client_socket, room_name}, _from, state) do
    room_participants = Map.get(state, room_name, MapSet.new())

    updated_participants = MapSet.delete(room_participants, client_socket)

    new_state =
      if MapSet.size(updated_participants) == 0 do
        Map.delete(state, room_name)
      else
        Map.put(state, room_name, updated_participants)
      end

    {:reply, :ok, new_state}
  end

  def handle_call({:get_participants, room_name}, _from, state) do
    {:reply, Map.get(state, room_name), state}
  end
end
