defmodule Swap.Utils.HttpClient do
  @moduledoc false

  use Tesla

  require Logger

  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Headers, [{"content-type", "application/json"}]

  def make_request_post(url, body) do
    now = NaiveDateTime.utc_now()

    client()
    |> post(url, body)
    |> handle_response(url, now)
  end

  defp handle_response({:ok, %Tesla.Env{status: 200, body: body}}, url, now) do
    Logger.info("http_client: status: 200, url: #{url}, date: #{now}")

    {:ok, 200, body}
  end

  defp handle_response({_, %Tesla.Env{status: status, body: body}}, url, now) do
    Logger.warn("http_client: status: #{status}, url: #{url}, date: #{now}")

    {:error, status, body}
  end

  defp handle_response(reason, url, now) do
    Logger.warn("http_client: url: #{url}, reason: #{inspect(reason)} date: #{now}")

    {:error, :unknown, reason}
  end

  defp client do
    Tesla.client([
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers,
       [
         {"content-type", "application/json"},
         {"user-agent", user_agent()}
       ]}
    ])
  end

  defp user_agent do
    app = Mix.Project.config()[:app] |> Atom.to_string()
    version = Mix.Project.config()[:version]

    "#{app}/#{version}"
  end
end
