defmodule ExSpeechlyTask do
  @moduledoc """
  Documentation for `ExSpeechlyTask`.

  This module implements an example usage for the [Speechly gRPC API](https://docs.speechly.com/speechly-api/).
  """
  require Logger

  @doc """
  Takes an audio file and transcribes it by calling the Speechly gRPC SLU API.

  The minimum sample rate is 8000Hz (16000Hz recommended),
  the minimum number of channels is one,
  and the only supported encoding so far is signed PCM.

  ## Examples

      iex> ExSpeechlyTask.speech_to_text("priv/test1_en.wav)
      "BANANAS APPLES"
  """
  def speech_to_text(path) do
    task = Task.async(ExSpeechlyTask, :stream, [path])

    Task.await(task)
  end

  def stream(path) do
    audio_chunks = File.stream!(path, [], 512)

    with {:ok, ref} = ExSpeechly.Slu.open_stream_subscription(self()) do
      ExSpeechly.Slu.configure_stream(ref)
      ExSpeechly.Slu.start_stream(ref)

      for chunk <- audio_chunks do
        maybe_wait_for_window_refill(ref)
        ExSpeechly.Slu.stream_audio_chunk(ref, chunk)
      end

      ExSpeechly.Slu.stop_stream(ref)
      handle_messages()
    end
  end

  # @see https://hexdocs.pm/mint/Mint.HTTP2.html#get_window_size/2-http-2-flow-control
  defp maybe_wait_for_window_refill(request_ref) do
    conn = :sys.get_state(ExSpeechly.Connection).mod_state.conn
    request_size = Mint.HTTP2.get_window_size(conn, {:request, request_ref})

    if request_size > 512 do
      :ok
    else
      maybe_wait_for_window_refill(request_ref)
    end
  end

  defp handle_messages(transcript \\ []) do
    receive do
      {_ref, %{streaming_response: {:transcript, %{word: word}}}} ->
        handle_messages([word | transcript])

      {_ref, %{streaming_response: {:finished, _message}}} ->
        transcript
        |> Enum.reverse()
        |> Enum.join(" ")

      {_ref, message} ->
        Logger.debug(inspect(message))
        handle_messages(transcript)
    end
  end
end
