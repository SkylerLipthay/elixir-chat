defmodule Chat.MixProject do
  use Mix.Project

  def project do
    [
      app: :chat,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Chat, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ratatouille, "~> 0.5.1"}
    ]
  end
end
