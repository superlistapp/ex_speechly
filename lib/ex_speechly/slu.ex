defmodule ExSpeechly.Slu do
  @moduledoc """
  The `ExSpeechly.Wlu` module implements GRPC calls to the [Speechly SLU API](https://docs.speechly.com/speechly-api/api-reference/#speechlysluv1slu).
  """

  alias ExSpeechly.Config
  alias ExSpeechly.TokenStore
  alias Speechly.Slu.V1.SLUConfig

  @doc """
  Starts a gRPC subscription to the Stream method.
  Returns the request reference, which is passed to every further call of the subscription.
  """
  @spec open_stream_subscription(pid(), fun()) :: {:ok, reference()} | {:error, any()}
  def open_stream_subscription(handler, through \\ &ref_msg_tuple/2) do
    rpc = %GrpcClient.Rpc{
      name: "Stream",
      request_type: Speechly.Slu.V1.SLURequest,
      request_stream?: true,
      response_type: Speechly.Slu.V1.SLUResponse,
      response_stream?: true,
      service: "Stream",
      service_module: "SLU",
      path: "/speechly.slu.v1.SLU/Stream"
    }

    authentication = "Bearer #{TokenStore.get_token()}"

    request = GrpcClient.Request.from_rpc(rpc, authentication)

    GenServer.call(ExSpeechly.Connection, {{:subscription, handler, through}, request}, 5000)
  end

  @doc """
  Half closes the connection by closing the subscription for the given request reference.
  """
  @spec close_stream_subscription(reference()) :: any()
  def close_stream_subscription(ref) do
    GenServer.call(ExSpeechly.Connection, {:close_subscription, ref}, 5000)
  end

  @default_config %SLUConfig{sample_rate_hertz: 16000, channels: 1}

  @doc """
  Sends the configuration of the audio that is about to be streamed to the subscription.
  This **must** be the first message in the subscription.
  """
  @spec configure_stream(reference(), Speechly.Slu.V1.SLUConfig.t()) :: :ok
  def configure_stream(ref, %SLUConfig{} = config \\ @default_config) do
    msg = %Speechly.Slu.V1.SLURequest{streaming_request: {:config, config}}

    GenServer.cast(ExSpeechly.Connection, {:push, ref, msg})
  end

  @doc """
  Sends the `SLUStart` message to the subscription, indicating the beginning of a logical audio segment.
  """
  @spec start_stream(reference()) :: :ok
  def start_stream(ref) do
    msg = %Speechly.Slu.V1.SLURequest{
      streaming_request: {:start, %Speechly.Slu.V1.SLUStart{app_id: Config.app_id()}}
    }

    GenServer.cast(ExSpeechly.Connection, {:push, ref, msg})
  end

  @doc """
  Streams a chunk of `audio` to the subscription
  """
  @spec stream_audio_chunk(reference(), binary()) :: :ok
  def stream_audio_chunk(ref, chunk) do
    msg = %Speechly.Slu.V1.SLURequest{streaming_request: {:audio, chunk}}

    GenServer.cast(ExSpeechly.Connection, {:push, ref, msg})
  end

  @doc """
  Sends the `SLUStop` message to the subscription, indicating the end of a logical audio segment.
  """
  @spec stop_stream(reference()) :: :ok
  def stop_stream(ref) do
    msg = %Speechly.Slu.V1.SLURequest{
      streaming_request: {:stop, %Speechly.Slu.V1.SLUStop{}}
    }

    GenServer.cast(ExSpeechly.Connection, {:push, ref, msg})
  end

  @doc """
  Sends the [`RoundTripMeasurementResponse`](https://docs.speechly.com/speechly-api/api-reference/#roundtripmeasurementresponse) message to the subscription.
  """
  @spec rtt_response(reference(), non_neg_integer()) :: :ok
  def rtt_response(ref, id) do
    msg = %Speechly.Slu.V1.SLURequest{
      streaming_request: {:rtt_response, %Speechly.Slu.V1.RoundTripMeasurementResponse{id: id}}
    }

    GenServer.cast(ExSpeechly.Connection, {:push, ref, msg})
  end

  @doc false
  def ref_msg_tuple(msg, ref), do: {ref, msg}
end
