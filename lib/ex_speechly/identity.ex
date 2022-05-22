defmodule ExSpeechly.Identity do
  @moduledoc """
  The `ExSpeechly.Identity` module implements GRPC calls to the [Speechly Identity API](https://docs.speechly.com/speechly-api/api-reference/#speechly.identity.v2.IdentityAPI).

  The Speechly Identity API is used for creating access tokens for the Speechly APIs.
  """

  alias ExSpeechly.Config

  @doc """
  Performs a login of specific Speechly application for the given `device_id` and either the
  `project_id` or `app_id`

  Returns an access token which can be used to access thee Speechly API.
  """
  @spec login(String.t(), %{app_id: String.t()} | %{project_id: String.t()}) ::
          {:ok, GrpcClient.Response.t()} | {:error, GrpcClient.Response.t() | any()}
  def login(device_id, %{app_id: app_id}) when is_binary(app_id) do
    msg = %Speechly.Identity.V2.LoginRequest{
      device_id: device_id,
      scope: {:application, %Speechly.Identity.V2.ApplicationScope{app_id: app_id}}
    }

    do_login(msg)
  end

  defp do_login(msg) do
    rpc = %GrpcClient.Rpc{
      name: "Login",
      request_type: Speechly.Identity.V2.LoginRequest,
      request_stream?: false,
      response_type: Speechly.Identity.V2.LoginResponse,
      response_stream?: false,
      service: "Login",
      service_module: "Identity",
      path: "/speechly.identity.v2.IdentityAPI/Login"
    }

    authentication = "Bearer #{Config.api_key()}"

    request = %{GrpcClient.Request.from_rpc(rpc, authentication) | messages: [msg]}

    with {:ok, resp} <- GenServer.call(ExSpeechly.Connection, {:request, request}, 5000) do
      case GrpcClient.Response.from_connection_response(resp, request.rpc, false) do
        %{status: :ok} = response -> {:ok, response}
        response -> {:error, response}
      end
    end
  end
end
