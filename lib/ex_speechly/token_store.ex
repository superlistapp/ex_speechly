defmodule ExSpeechly.TokenStore do
  @moduledoc """
  The `ExSpeechly.TokenStore` authenticates the client through the
  Speechly Identity API and stores the access token for the Speechly APIs in an ETS table.

  It automatically refreshes the token before it expires.
  """

  use GenServer, restart: :transient

  alias ExSpeechly.Config
  alias ExSpeechly.Identity

  require Logger

  def start_link(_) do
    GenServer.start_link(ExSpeechly.TokenStore, %{}, name: ExSpeechly.TokenStore)
  end

  def init(_) do
    find_or_create_ets_table()

    scope = %{app_id: Config.app_id(), project_id: Config.project_id()}

    case Identity.login(Config.device_id(), scope) do
      {:ok, %{status: :ok, data: identity}} ->
        store_data_to_ets(identity)
        Logger.debug("Stored speechly identity token in token store. ")
        # Refresh identity before it expires
        schedule_refresh(identity.valid_for_s - 10)
        {:ok, %{}}

      {:error, %{message: message}} ->
        {:stop,
         """
         Could not login into with speechly identity.

         Error message: #{inspect(message)}
         """}

      _ ->
        {:stop, "Could not login into with speechly identity."}
    end
  end

  def get_token() do
    GenServer.call(ExSpeechly.TokenStore, :get_token)
  end

  def handle_call(:get_token, _from, state) do
    token =
      ExSpeechly.TokenStore
      |> :ets.lookup(:token)
      |> Keyword.get(:token)

    {:reply, token, state}
  end

  def handle_info(:refresh, state) do
    case Identity.login(Config.device_id(), project_id: Config.project_id()) do
      # If everything went okay, refresh at the regular interval and store the returned keys in state.
      {:ok, %{status: :ok, data: identity}} ->
        store_data_to_ets(identity)

        Logger.debug("Refreshed speechly identity.")
        schedule_refresh(identity.valid_for_s)

      # Keep trying with a lower interval, until then keep the old state.
      {:error, %{message: message}} ->
        Logger.warn("""
        Refreshing speechly identity failed, using old state and retrying...

        Error message: #{inspect(message)}
        """)

        schedule_refresh(10)
    end

    {:noreply, state}
  end

  defp find_or_create_ets_table do
    case :ets.whereis(ExSpeechly.TokenStore) do
      :undefined -> :ets.new(ExSpeechly.TokenStore, [:set, :public, :named_table])
      table -> table
    end
  end

  defp store_data_to_ets(data) when is_struct(data) do
    data
    |> Map.from_struct()
    |> Enum.each(fn {key, value} ->
      :ets.insert(ExSpeechly.TokenStore, {key, value})
    end)
  end

  defp schedule_refresh(after_s) do
    Process.send_after(self(), :refresh, after_s * 1000)
  end
end
