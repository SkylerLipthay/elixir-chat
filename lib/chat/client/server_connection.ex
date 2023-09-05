defmodule Chat.Client.ServerConnection do
  use GenServer

  def start_link({host, port}) do
    GenServer.start_link(__MODULE__, {host, port}, name: __MODULE__)
  end

  def init({host, port}) do
    {:ok, socket} = :gen_tcp.connect(host, port, [:binary, packet: 2, active: true])
    {:ok, %{socket: socket}}
  end

  def send_message(message) do
    GenServer.cast(__MODULE__, {:send, message})
  end

  def handle_cast({:send, message}, %{socket: socket} = state) do
    :ok = :gen_tcp.send(socket, message)
    {:noreply, state}
  end

  def handle_info({:tcp, _socket, data}, state) do
    Chat.Client.IncomingBuffer.append("Server", data)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _}, state), do: {:stop, :normal, state}
  def handle_info({:tcp_error, _}, state), do: {:stop, :normal, state}
end
