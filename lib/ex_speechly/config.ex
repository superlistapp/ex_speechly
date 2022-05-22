defmodule ExSpeechly.Config do
  @moduledoc """
  Configuration for the ExSpeechly client.
  """

  def config, do: Application.get_all_env(:ex_speechly)
  def device_id, do: Keyword.get(config(), :device_id)
  def project_id, do: Keyword.get(config(), :project_id)
  def app_id, do: Keyword.get(config(), :app_id)
  def api_key, do: Keyword.get(config(), :api_key)
  def host, do: Keyword.get(config(), :host)
end
