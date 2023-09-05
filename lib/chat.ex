defmodule Chat do
  use Application

  def start(_type, _args) do
    case System.argv() do
      ["server", port] ->
        port = String.to_integer(port)
        Chat.Server.Supervisor.start_link(port)

      ["client", host, port] ->
        {:ok, host} = host |> String.to_charlist() |> :inet.parse_address()
        port = String.to_integer(port)
        Chat.Client.Supervisor.start_link({host, port})

      _ ->
        IO.puts("Specify either \"server\" or \"client\"")
        System.halt(1)
    end
  end

  def stop(_) do
    System.halt(0)
  end
end
