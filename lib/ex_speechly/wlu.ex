defmodule ExSpeechly.Wlu do
  @moduledoc """
  The `ExSpeechly.Wlu` module implements GRPC calls to the [Speechly WLU API](https://docs.speechly.com/speechly-api/api-reference/#speechlysluv1wlu).
  """

  alias ExSpeechly.Config
  alias ExSpeechly.TokenStore

  @typedoc """
  The language of the text sent in the request as a BCP-47 language tag (e.g. `"en-US"`).
  """
  @type bcp_47_language_code() :: String.t()

  @typedoc """
  An epoch unix timestamp in seconds. (e.g. `System.system_time(:second)`)
  """
  @type timestamp() :: pos_integer()

  @doc """
  Performs recognition of a text with the specified language.

  Takes the following 3 parameters:

    * `text`, The text to recognize.
    * `language_code`, The language of the text sent in the request as a BCP-47 language tag (e.g. “en-US”).
    * `reference_time` (Optional), The reference time for postprocessing. By default, the current date is used.

  ## Examples

      iex> ExSpeechly.Wlu.recognize_text("Oh wow, is this the new Speechly hoodie?", "en-US")
      {:ok,
        %GrpcClient.Response{
        data: %Speechly.Slu.V1.WLUResponse{
          __uf__: [],
          segments: [
            %Speechly.Slu.V1.WLUSegment{
              __uf__: [],
              annotated_text: "*select oh wow is this the new [speechly|speechly](brand) hoodie",
              entities: [
                %Speechly.Slu.V1.WLUEntity{
                  __uf__: [],
                  end_position: 8,
                  entity: "brand",
                  start_position: 7,
                  value: "SPEECHLY"
                }
              ],
              intent: %Speechly.Slu.V1.WLUIntent{__uf__: [], intent: "select"},
              text: "OH WOW IS THIS THE NEW SPEECHLY HOODIE",
              tokens: [
                %Speechly.Slu.V1.WLUToken{__uf__: [], index: 0, word: "OH"},
                %Speechly.Slu.V1.WLUToken{__uf__: [], index: 1, word: "WOW"},
                %Speechly.Slu.V1.WLUToken{__uf__: [], index: 2, word: "IS"},
                %Speechly.Slu.V1.WLUToken{__uf__: [], index: 3, word: "THIS"},
                %Speechly.Slu.V1.WLUToken{__uf__: [], index: 4, word: "THE"},
                %Speechly.Slu.V1.WLUToken{__uf__: [], index: 5, word: "NEW"},
                %Speechly.Slu.V1.WLUToken{__uf__: [], index: 6, word: "SPEECHLY"},
                %Speechly.Slu.V1.WLUToken{__uf__: [], index: 7, word: "HOODIE"}
              ]
            }
          ]
        },
        message: "",
        status: :ok,
        status_code: 0
        }}
  """
  @spec recognize_text(String.t(), bcp_47_language_code(), timestamp()) ::
          {:ok, GrpcClient.Response.t()} | {:error, GrpcClient.Response.t() | any()}
  def recognize_text(text, language_code, reference_time \\ System.system_time(:second)) do
    rpc = %GrpcClient.Rpc{
      name: "Text",
      request_type: Speechly.Slu.V1.WLURequest,
      request_stream?: false,
      response_type: Speechly.Slu.V1.WLUResponse,
      response_stream?: false,
      service: "Text",
      service_module: "WLU",
      path: "/speechly.slu.v1.WLU/Text"
    }

    authentication = "Bearer #{TokenStore.get_token()}"

    msg = %Speechly.Slu.V1.WLURequest{
      text: text,
      language_code: language_code,
      reference_time: %Google.Protobuf.Timestamp{seconds: reference_time}
    }

    request = %{GrpcClient.Request.from_rpc(rpc, authentication) | messages: [msg]}

    with {:ok, resp} <- GenServer.call(ExSpeechly.Connection, {:request, request}, 5000) do
      case GrpcClient.Response.from_connection_response(resp, request.rpc, false) do
        %{status: :ok} = response -> {:ok, response}
        response -> {:error, response}
      end
    end
  end

  @doc """
  Performs recognition of a batch of texts with the specified language.

  Takes the following 2 parameters:

    * `texts`, A list of tuples containing the languagce code and the text to recognize (e.g. `[{"en-US, "Oh wow, is this the new Speechly hoodie?"}]`).
    * `reference_time` (Optional), The reference time for postprocessing. By default, the current date is used.

  ## Examples

      iex> ExSpeechly.Wlu.batch_recognize_texts([{"Oh wow, is this the new Speechly hoodie?"}])
      {:ok,
        %GrpcClient.Response{
          data: %Speechly.Slu.V1.TextsResponse{
            __uf__: [],
            responses: [
              %Speechly.Slu.V1.WLUResponse{
                __uf__: [],
                segments: [
                  %Speechly.Slu.V1.WLUSegment{
                    __uf__: [],
                    annotated_text: "*select oh wow is this the new speechly hoodie",
                    entities: [
                      %Speechly.Slu.V1.WLUEntity{
                        __uf__: [],
                        end_position: 8,
                        entity: "brand",
                        start_position: 7,
                        value: "SPEECHLY"
                      }
                    ],
                    intent: %Speechly.Slu.V1.WLUIntent{__uf__: [], intent: "select"},
                    text: "OH WOW IS THIS THE NEW SPEECHLY HOODIE",
                    tokens: [
                      %Speechly.Slu.V1.WLUToken{__uf__: [], index: 0, word: "OH"},
                      %Speechly.Slu.V1.WLUToken{__uf__: [], index: 1, word: "WOW"},
                      %Speechly.Slu.V1.WLUToken{__uf__: [], index: 2, word: "IS"},
                      %Speechly.Slu.V1.WLUToken{__uf__: [], index: 3, word: "THIS"},
                      %Speechly.Slu.V1.WLUToken{__uf__: [], index: 4, word: "THE"},
                      %Speechly.Slu.V1.WLUToken{__uf__: [], index: 5, word: "NEW"},
                      %Speechly.Slu.V1.WLUToken{__uf__: [], index: 6, word: "SPEECHLY"},
                      %Speechly.Slu.V1.WLUToken{__uf__: [], index: 7, word: "HOODIE"}
                    ]
                  }
                ]
              }
            ]
          },
          message: "",
          status: :ok,
          status_code: 0
        }}
  """
  @spec batch_recognize_texts([{bcp_47_language_code(), String.t()}, ...], timestamp()) ::
          {:ok, GrpcClient.Response.t()} | {:error, GrpcClient.Response.t() | any()}
  def batch_recognize_texts(texts, reference_time \\ System.system_time(:second)) do
    rpc = %GrpcClient.Rpc{
      name: "Texts",
      request_type: Speechly.Slu.V1.TextsRequest,
      request_stream?: false,
      response_type: Speechly.Slu.V1.TextsResponse,
      response_stream?: false,
      service: "Texts",
      service_module: "WLU",
      path: "/speechly.slu.v1.WLU/Texts"
    }

    authentication = "Bearer #{TokenStore.get_token()}"

    requests =
      for {language_code, text} <- texts do
        %Speechly.Slu.V1.WLURequest{
          text: text,
          language_code: language_code,
          reference_time: %Google.Protobuf.Timestamp{seconds: reference_time}
        }
      end

    msg = %Speechly.Slu.V1.TextsRequest{
      app_id: Config.app_id(),
      requests: requests
    }

    request = %{GrpcClient.Request.from_rpc(rpc, authentication) | messages: [msg]}

    with {:ok, resp} <- GenServer.call(ExSpeechly.Connection, {:request, request}, 5000) do
      case GrpcClient.Response.from_connection_response(resp, request.rpc, false) do
        %{status: :ok} = response -> {:ok, response}
        response -> {:error, response}
      end
    end
  end
end
