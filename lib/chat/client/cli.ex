defmodule Chat.Client.Cli do
  @behaviour Ratatouille.App

  alias Ratatouille.Runtime.Subscription

  import Ratatouille.View
  import Ratatouille.Constants, only: [key: 1]

  @spacebar key(:space)
  @enter key(:enter)

  @delete_keys [
    key(:delete),
    key(:backspace),
    key(:backspace2)
  ]

  def init(_context) do
    %{received: [], outgoing: "", line_count: 0}
  end

  def update(%{received: received, outgoing: outgoing, line_count: line_count} = model, message) do
    case message do
      {:event, %{key: key}} when key in @delete_keys ->
        %{model | outgoing: String.slice(outgoing, 0..-2)}

      {:event, %{key: @spacebar}} ->
        %{model | outgoing: outgoing <> " "}

      {:event, %{key: @enter}} ->
        Chat.Client.OutgoingDispatch.handle(outgoing)
        %{model | outgoing: ""}

      {:event, %{ch: ch}} when ch > 0 ->
        %{model | outgoing: outgoing <> <<ch::utf8>>}

      :tick ->
        new_messages = Chat.Client.IncomingBuffer.flush()
        reducer = fn message, sum -> sum + line_count_for_message(message) end
        new_line_count = line_count + Enum.reduce(new_messages, 0, reducer)
        %{model | received: received ++ new_messages, line_count: new_line_count}

      _ ->
        model
    end
  end

  def subscribe(_model) do
    Subscription.interval(100, :tick)
  end

  def render(model) do
    view(top_bar: title_bar(), bottom_bar: chat_bar(model)) do
      panel(height: :fill, padding: 0) do
        viewport([offset_y: offset_y(model)], messages_view(model))
      end
    end
  end

  defp line_count_for_message({_from, _time, message}) do
    Enum.count(String.graphemes(message), &(&1 == "\n")) + 3
  end

  defp offset_y(model) do
    {:ok, screen_rows} = :io.rows()
    max(0, model.line_count - (screen_rows - 3))
  end

  defp title_bar do
    bar do
      label do
        text(content: "Chat client")
        text(content: " (type /help)", color: :black)
      end
    end
  end

  defp chat_bar(%{outgoing: outgoing}) do
    bar do
      case outgoing do
        "" ->
          label(content: "> Type a message and press enter to send", color: :black)

        _ ->
          label do
            text(content: "> ", color: :black)
            text(content: outgoing)
          end
      end
    end
  end

  def messages_view(%{received: received}) do
    Enum.flat_map(received, fn {from, time, message} ->
      [
        label(content: "#{from} @ #{time}", color: :black),
        label(content: message),
        label(content: "")
      ]
    end)
  end
end
