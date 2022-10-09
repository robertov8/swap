defmodule Swap.Providers.Github do
  @moduledoc """
  Esse modulo contem a camada de tradução entre a resposta
  github e a resposta resperada pelo resto da aplicação
  """

  @behaviour Swap.Providers

  alias Swap.Clients
  alias Swap.Clients.Github.Response, as: ClientResponse
  alias Swap.Providers.Response, as: ProviderResponse

  @impl true
  def limit_reached?(token) do
    case Clients.Github.rate_limit(token) do
      {:ok, %ClientResponse.RateLimit{remaining: 0}} ->
        true

      {:ok, %ClientResponse.RateLimit{remaining: _remaining}} ->
        false

      _ ->
        true
    end
  end

  @impl true
  def get_repo(owner, repo, token) do
    with {:ok, issues} <- Clients.Github.repo_issues(owner, repo, token),
         {:ok, contributors} <- Clients.Github.repo_contributors(owner, repo, token) do
      {:ok,
       %ProviderResponse.Repository{
         user: owner,
         repository: repo,
         issues: Enum.map(issues, &parse_issues/1),
         contributors: Enum.map(contributors, &parse_contributors/1)
       }}
    end
  end

  defp parse_issues(issue) do
    %{title: issue.title, author: issue.login, labels: issue.labels}
  end

  defp parse_contributors(contributor) do
    %{name: contributor.login, user: contributor.url, qtd_commits: contributor.contributions}
  end
end
