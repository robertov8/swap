defmodule Swap.Clients.Github do
  @moduledoc false

  @type response :: {:ok | :error, list() | struct()}

  @callback repo_issues(owner :: String.t(), repo :: String.t()) :: response
  @callback repo_contributors(owner :: String.t(), repo :: String.t()) :: response

  def repo_issues(owner, repo), do: adapter().repo_issues(owner, repo)
  def repo_contributors(owner, repo), do: adapter().repo_contributors(owner, repo)

  def adapter, do: Application.fetch_env!(:swap, :client_github_adapter)
end
