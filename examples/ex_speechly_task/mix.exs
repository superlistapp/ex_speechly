defmodule ExSpeechlyTask.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_speechly_task,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_speechly, github: "superlistapp/ex_speechly"}
    ]
  end
end
