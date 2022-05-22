defmodule ExSpeechly.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_speechly,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExSpeechly.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:grpc_client, "~> 0.1.1"},
      {:speechly_protox, github: "superlistapp/speechly_protox"}
    ]
  end
end
