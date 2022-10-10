defmodule Swap.Clients.Github do
  @moduledoc false

  @type response :: {:ok | :error, atom() | list() | struct()}

  @callback repo_issues(owner :: String.t(), repo :: String.t(), token :: String.t() | nil) ::
              response()

  @callback repo_contributors(owner :: String.t(), repo :: String.t(), token :: String.t() | nil) ::
              response()

  @callback rate_limit(token :: String.t() | nil) :: response()

  def repo_issues(owner, repo, token \\ nil), do: adapter().repo_issues(owner, repo, token)

  def repo_contributors(owner, repo, token \\ nil),
    do: adapter().repo_contributors(owner, repo, token)

  def rate_limit(token \\ nil), do: adapter().rate_limit(token)

  def adapter, do: Application.fetch_env!(:swap, :client_github_adapter)
end
