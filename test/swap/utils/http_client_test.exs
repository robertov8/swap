defmodule Swap.Utils.HTTPClientTest do
  @moduledoc false

  use ExUnit.Case

  import Tesla.Mock
  import ExUnit.CaptureLog

  alias Utils.HTTPClient

  describe "make_post_request/2" do
    setup do
      mock(fn
        %{method: :post, url: "http://swap.com.br/webhook"} ->
          setup_http(200, %{"status" => "ok"})

        %{method: :post, url: "http://invalid.com.br/webhook"} ->
          setup_http(500, %{"status" => "error"})

        %{method: :post, url: "http://timeout.com.br/webhook"} ->
          setup_http_invalid_request()
      end)
    end

    test "when the repository is valid, returns success" do
      response = HTTPClient.make_post_request("http://swap.com.br/webhook", %{"data" => %{}})

      expected_response = {:ok, 200, %{"status" => "ok"}}

      assert expected_response == response
    end

    test "when the response is valid, returns error" do
      {_result, log} =
        with_log(fn ->
          response =
            HTTPClient.make_post_request("http://invalid.com.br/webhook", %{"data" => %{}})

          expected_response = {:error, 500, %{"status" => "error"}}

          assert expected_response == response
        end)

      assert log =~ "status: 500"

      {_result, log} =
        with_log(fn ->
          response =
            HTTPClient.make_post_request("http://timeout.com.br/webhook", %{"data" => %{}})

          expected_response = {:error, :unknown, {:error, :timeout}}

          assert expected_response == response
        end)

      assert log =~ "reason: {:error, :timeout}"
    end
  end

  defp setup_http(status, body) do
    {:ok,
     %Tesla.Env{
       headers: [{"Content-Type", "application/json; charset=utf-8"}],
       body: body,
       method: :get,
       opts: [],
       query: [],
       status: status,
       url: "https://webhook.site"
     }}
  end

  defp setup_http_invalid_request do
    {:error, :timeout}
  end
end
