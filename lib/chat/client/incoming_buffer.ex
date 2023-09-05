defmodule Chat.Client.IncomingBuffer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, [{"System", local_time(), "Initializing connection to server."}]}
  end

  def flush do
    GenServer.call(__MODULE__, :flush)
  end

  def append(from, message) do
    GenServer.cast(__MODULE__, {:accept, from, message})
  end

  def handle_call(:flush, _from, messages) do
    {:reply, messages, []}
  end

  def handle_cast({:accept, from, message}, messages) do
    {:noreply, messages ++ [{from, local_time(), message}]}
  end

  defp local_time do
    utc_time = :calendar.universal_time()
    local_time = :calendar.universal_time_to_local_time(utc_time)
    format_datetime(local_time)
  end

  defp format_datetime({{year, month, day}, {hour, minute, second}}) do
    "#{year}-#{pad(month)}-#{pad(day)} #{pad(hour)}:#{pad(minute)}:#{pad(second)}"
  end

  defp pad(number) when number < 10, do: "0#{number}"
  defp pad(number), do: number
end
