defmodule Swap.Clients.Github.Http do
  @moduledoc false

  @behaviour Swap.Clients.Github

  use Tesla

  alias Swap.Clients.Github.Response
  alias Tesla.Env

  @type response :: {:ok | :error, struct()}

  plug Tesla.Middleware.BaseUrl, base_url()
  plug Tesla.Middleware.Headers, [{"Accept", "application/vnd.github+json"}]
  plug Tesla.Middleware.JSON

  @impl true
  @spec repo_issues(owner :: String.t(), repo :: String.t()) :: response()
  def repo_issues(owner, repo) do
    "/repos/#{owner}/#{repo}/issues"
    |> get()
    |> handle_response()
    |> Response.parse(:issues)
  end

  @impl true
  @spec repo_contributors(owner :: String.t(), repo :: String.t()) :: response()
  def repo_contributors(owner, repo) do
    "/repos/#{owner}/#{repo}/contributors"
    |> get()
    |> handle_response()
    |> Response.parse(:contributors)
  end

  defp handle_response({:ok, %Env{body: %{"documentation_url" => _, "message" => message}}}) do
    {:error, message}
  end

  defp handle_response({:ok, %Env{body: body}}), do: {:ok, body}

  defp handle_response({_status, %Env{status: status}}), do: {:error, status}

  defp base_url, do: Application.fetch_env!(:swap, :client_github_base_url)
end
