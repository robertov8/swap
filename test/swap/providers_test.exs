defmodule Swap.ProvidersTest do
  @moduledoc false

  use Swap.DataCase

  alias Swap.Clients.Github.Mock, as: GithubMock
  alias Swap.Providers.Response

  setup do
    Hammox.stub(ClientFakeGithubMock, :rate_limit, &GithubMock.rate_limit/1)
    Hammox.stub(ClientFakeGithubMock, :repo_issues, &GithubMock.repo_issues/3)
    Hammox.stub(ClientFakeGithubMock, :repo_contributors, &GithubMock.repo_contributors/3)

    :ok
  end

  describe "limit_reached?/1" do
    test "when the token is valid, returns response" do
      webhook = insert(:webhook, repository_token: "token")

      refute Swap.Providers.limit_reached?(webhook)
    end

    test "when the token is nil, returns false" do
      webhook = insert(:webhook, repository_token: nil)

      assert Swap.Providers.limit_reached?(webhook)
    end
  end

  describe "get_repo/2" do
    test "when the repository is valid, returns response" do
      repository = insert(:repository, name: "valid_repo")
      webhook = insert(:webhook, repository: repository)

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
             } = Swap.Providers.get_repo(webhook)
    end

    test "when the repository is invalid, returns nil" do
      repository = insert(:repository, name: "invalid_repo")
      webhook = insert(:webhook, repository: repository)

      refute Swap.Providers.get_repo(webhook)
    end
  end
end
