defmodule Swap.ProvidersTest do
  @moduledoc false

  use ExUnit.Case

  alias Swap.Clients.Github.Mock, as: GithubMock
  alias Swap.Providers.Response

  setup do
    Hammox.stub(ClientFakeGithubMock, :repo_issues, &GithubMock.repo_issues/2)
    Hammox.stub(ClientFakeGithubMock, :repo_contributors, &GithubMock.repo_contributors/2)

    :ok
  end

  describe "get_repo/2 github" do
    test "when the response is valid, returns response" do
      assert %Response.Repository{
               user: "swap",
               repository: "valid_repo",
               issues: [
                 %{
                   author: "octocat",
                   labels: [%{description: "Something isn't working", name: "bug"}],
                   title: "Found a bug"
                 }
               ],
               contributors: [
                 %{
                   name: "octocat",
                   qtd_commits: 32,
                   user: "https://api.github.com/users/octocat"
                 }
               ]
             } = Swap.Providers.get_repo("swap", "valid_repo", :github)
    end

    test "when the answer is invalid, returns nil" do
      refute Swap.Providers.get_repo("swap", "invalid_repo")
    end
  end
end
