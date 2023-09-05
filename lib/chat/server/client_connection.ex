defmodule Chat.Server.ClientConnection do
  use GenServer

  def start_link({socket}) do
    GenServer.start_link(__MODULE__, {socket})
  end

  def init({socket}) do
    IO.puts("Client #{inspect(self())} connected")
    {:ok, %{socket: socket, current_room: nil}}
  end

  def get_socket(pid) do
    GenServer.call(pid, :get_socket)
  end

  def handle_call(:get_socket, _from, state) do
    {:reply, state.socket, state}
  end

  def handle_info({:tcp, _socket, data}, state) do
    handle_client_message(data, state)
  end

  def handle_info({:tcp_closed, _socket}, state) do
    IO.puts("Client #{inspect(self())} disconnected")

    if state.current_room do
      Chat.Server.RoomRegistry.leave_room(state.socket, state.current_room)
    end

    {:stop, :normal, state}
  end

  defp handle_client_message(data, state) do
    if String.starts_with?(data, "/") do
      handle_command(String.split(data, " "), state)
    else
      handle_message(data, state)
    end
  end

  defp handle_command(["/list"], state) do
    rooms = Chat.Server.RoomRegistry.list_rooms()

    send_to_client(
      state.socket,
      case rooms do
        [] -> "There are no rooms."
        _ -> "Rooms: " <> Enum.join(rooms, ", ")
      end
    )

    {:noreply, state}
  end

  defp handle_command(["/join", room_name], state) do
    if state.current_room do
      Chat.Server.RoomRegistry.leave_room(state.socket, state.current_room)
    end

    Chat.Server.RoomRegistry.join_room(state.socket, room_name)

    case state.current_room do
      nil -> send_to_client(state.socket, "You have joined #{room_name}.")
      current -> send_to_client(state.socket, "You have left #{current} and joined #{room_name}.")
    end

    {:noreply, %{state | current_room: room_name}}
  end

  defp handle_command(["/leave"], state) do
    if state.current_room do
      send_to_client(state.socket, "You have left #{state.current_room}.")
      Chat.Server.RoomRegistry.leave_room(state.socket, state.current_room)
    else
      send_to_client(state.socket, "You're not in a room.")
    end

    {:noreply, %{state | current_room: nil}}
  end

  defp handle_command(_, state) do
    send_to_client(state.socket, "Invalid command.")
    {:noreply, state}
  end

  defp handle_message(message, state) do
    case state.current_room do
      nil ->
        send_to_client(state.socket, "You're not in a room. Join a room to start chatting!")
        {:noreply, state}

      room_name ->
        Chat.Server.RoomRegistry.get_participants(room_name)
        |> Enum.each(&send_to_client(&1, "[#{inspect(self())}] #{message}"))

        {:noreply, state}
    end
  end

  defp send_to_client(socket, msg), do: :gen_tcp.send(socket, msg)
end
