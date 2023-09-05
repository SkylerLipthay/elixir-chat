defmodule Chat.Client.OutgoingDispatch do
  @help_message """
                Available commands:
                  /list                Lists all existing rooms.
                  /join <room_name>    Joins a room by name, creating it first if it doesn't exist.
                  /leave               Leaves the current room.
                  /help                Displays this message.
                Press Ctrl+C to exit.
                """
                |> String.trim()

  def handle(data) do
    if data == "/help" do
      Chat.Client.IncomingBuffer.append("System", @help_message)
    else
      Chat.Client.ServerConnection.send_message(data)
    end
  end
end
