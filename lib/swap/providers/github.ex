defmodule Swap.Providers.Github do
  @moduledoc """
  This module contains the translation layer between the response
  github and the response expected by the rest of the application
  """

  @behaviour Swap.Providers

  alias Swap.Clients
  alias Swap.Clients.Github.Response, as: ClientResponse
  alias Swap.Providers.Response, as: ProviderResponse

  @impl true
  def limit_reached(token) do
    case Clients.Github.rate_limit(token) do
      {:ok, %ClientResponse.RateLimit{remaining: 0}} ->
        {:error, 0}

      {:ok, %ClientResponse.RateLimit{remaining: remaining}} ->
        {:ok, remaining}

      reason ->
        reason
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
    %ProviderResponse.Issue{
      title: issue.title,
      author: issue.login,
      labels: issue.labels
    }
  end

  defp parse_contributors(contributor) do
    %ProviderResponse.Contributor{
      name: contributor.login,
      user: nil,
      qtd_commits: contributor.contributions
    }
  end

  @impl true
  def get_user(username, token) do
    case Clients.Github.user(username, token) do
      {:ok, user} ->
        %ProviderResponse.User{
          login: user.login,
          url: user.url,
          name: user.name,
          avatar_url: user.avatar_url,
          company: user.company,
          email: user.email
        }

      {:error, _reason} ->
        %ProviderResponse.User{
          login: username
        }
    end
  end
end
