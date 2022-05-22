defmodule ExSpeechly.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias ExSpeechly.Config

  @impl true
  def start(_type, _args) do
    children = [
      {GrpcClient.Connection, name: ExSpeechly.Connection, url: Config.host()},
      ExSpeechly.TokenStore
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExSpeechly.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
