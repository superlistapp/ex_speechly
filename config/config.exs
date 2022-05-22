import Config

config :ex_speechly,
  api_key: "",
  device_id: "",
  project_id: "",
  app_id: "",
  host: "https://api.speechly.com:443"

if File.exists?("config/secret.exs"), do: import_config("secret.exs")
