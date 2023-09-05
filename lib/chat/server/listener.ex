defmodule Chat.Server.Listener do
  use GenServer

  def start_link([port]) do
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  def init(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: 2, active: true, reuseaddr: true])
    IO.puts("Listening on port #{port}")
    {:ok, %{socket: socket}, {:continue, :accept_clients}}
  end

  def handle_continue(:accept_clients, state) do
    {:ok, client_socket} = :gen_tcp.accept(state.socket)

    {:ok, client_handler_pid} = Chat.Server.ClientConnection.start_link({client_socket})
    :ok = :gen_tcp.controlling_process(client_socket, client_handler_pid)

    {:noreply, state, {:continue, :accept_clients}}
  end
end
