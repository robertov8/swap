defmodule Swap.Clients.Github.Http do
  @moduledoc false

  @behaviour Swap.Clients.Github

  use Tesla

  alias Swap.Clients.Github.Response
  alias Tesla.Env

  @type response :: {:ok | :error, struct()}

  @impl true
  @spec repo_issues(owner :: String.t(), repo :: String.t(), token :: String.t() | nil) ::
          response()
  def repo_issues(owner, repo, token) do
    token
    |> client()
    |> get("/repos/#{owner}/#{repo}/issues")
    |> handle_response()
    |> Response.parse(:issues)
  end

  @impl true
  @spec repo_contributors(owner :: String.t(), repo :: String.t(), token :: String.t() | nil) ::
          response()
  def repo_contributors(owner, repo, token) do
    token
    |> client()
    |> get("/repos/#{owner}/#{repo}/contributors")
    |> handle_response()
    |> Response.parse(:contributors)
  end

  @impl true
  @spec rate_limit(token :: String.t() | nil) :: response()
  def rate_limit(token) do
    token
    |> client()
    |> get("/rate_limit")
    |> handle_response()
    |> Response.parse(:rate_limit)
  end

  @impl true
  @spec user(username :: String.t(), token :: String.t() | nil) :: response()
  def user(username, token) do
    token
    |> client()
    |> get("/users/#{username}")
    |> handle_response()
    |> Response.parse(:user)
  end

  defp handle_response({:ok, %Env{body: %{"documentation_url" => _, "message" => message}}}) do
    {:error, message}
  end

  defp handle_response({:ok, %Env{body: body}}), do: {:ok, body}

  defp handle_response({_status, %Env{status: status}}), do: {:error, status}

  defp client(token) do
    authorization =
      if token do
        [{"Authorization", "Bearer #{token}"}]
      else
        []
      end

    Tesla.client([
      Tesla.Middleware.JSON,
      {Tesla.Middleware.BaseUrl, base_url()},
      {Tesla.Middleware.Headers, [{"Accept", "application/vnd.github+json"}] ++ authorization}
    ])
  end

  defp base_url, do: Application.fetch_env!(:swap, :client_github_base_url)
end
