defmodule Swap.Clients.Github.Mock do
  @moduledoc false

  @behaviour Swap.Clients.Github

  alias Swap.Clients.Github.Response

  @impl true
  def repo_issues(_owner, "valid_repo", _token) do
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

  def repo_issues(_owner, "invalid_repo", _token) do
    {:error,
     %Swap.Clients.Github.Response.Error{
       reason: "Error",
       status: 500
     }}
  end

  @impl true
  def repo_contributors(_owner, "valid_repo", _token) do
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

  def repo_contributors(_owner, "invalid_repo", _token) do
    {:error,
     %Swap.Clients.Github.Response.Error{
       reason: "Error",
       status: 500
     }}
  end
end
