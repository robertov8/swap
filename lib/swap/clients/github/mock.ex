defmodule Swap.Clients.Github.Mock do
  @moduledoc false

  @behaviour Swap.Clients.Github

  alias Swap.Clients.Github.Response

  @impl true
  def repo_issues(owner, repo, _token), do: repo_issues(owner, repo)

  def repo_issues(_owner, "valid_repo") do
    {:ok,
     [
       %Response.Issue{
         id: 1,
         title: "Found a bug",
         login: "octocat",
         labels: [%{description: "Something isn't working", name: "bug"}]
       }
     ]}
  end

  def repo_issues(_owner, "invalid_repo") do
    {:error,
     %Response.Error{
       reason: "Error",
       status: 500
     }}
  end

  @impl true
  def repo_contributors(owner, repo, _token), do: repo_contributors(owner, repo)

  def repo_contributors(_owner, "valid_repo") do
    {:ok,
     [
       %Response.Contributor{
         id: 1,
         contributions: 32,
         login: "octocat",
         url: "https://api.github.com/users/octocat"
       }
     ]}
  end

  def repo_contributors(_owner, "invalid_repo") do
    {:error,
     %Response.Error{
       reason: "Error",
       status: 500
     }}
  end

  @impl true
  def rate_limit(nil) do
    {:ok,
     %Response.RateLimit{
       limit: 5000,
       remaining: 0,
       reset: 1_665_327_096,
       used: 5000
     }}
  end

  def rate_limit("token") do
    {:ok,
     %Response.RateLimit{
       limit: 5000,
       remaining: 4997,
       reset: 1_665_327_096,
       used: 3
     }}
  end

  def rate_limit("invalid") do
    {:error, :timeout}
  end
end
