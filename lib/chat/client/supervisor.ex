defmodule Chat.Client.Supervisor do
  use Supervisor

  def start_link({host, port}) do
    Supervisor.start_link(__MODULE__, {host, port}, name: __MODULE__)
  end

  def init({host, port}) do
    children = [
      {
        Ratatouille.Runtime.Supervisor,
        runtime: [
          app: Chat.Client.Cli,
          quit_events: [{:key, Ratatouille.Constants.key(:ctrl_c)}],
          interval: 100,
          shutdown: {:application, :chat}
        ]
      },
      {Chat.Client.ServerConnection, {host, port}},
      Chat.Client.IncomingBuffer
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
