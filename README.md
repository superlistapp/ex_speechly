# ExSpeechly

An elixir client implementation for the [Speechly gRPC API](https://github.com/speechly/api).

## Installation

The package can be installed by adding `ex_speechly` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_speechly, github: "superlistapp/ex_speechly"}
  ]
end
```

Add the following configuration to your `config.exs`:

```elixir
config :ex_speechly,
  api_key: "", # The api key found in the Speechly dashboard.
  device_id: "", # A UUID identifying your elixir client.
  project_id: "", # The project id found in the Speechly dashboard.
  app_id: "", # The app id found in the Speechly dashboard.
  host: "https://api.speechly.com:443" # Optional. Defaults to https://api.speechly.com:443
```
