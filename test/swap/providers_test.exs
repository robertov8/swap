defmodule Swap.ProvidersTest do
  @moduledoc false

  use Swap.DataCase

  alias Swap.Cache
  alias Swap.Clients.Github.Mock, as: GithubMock
  alias Swap.Providers
  alias Swap.Providers.Response

  setup do
    Hammox.stub(ClientFakeGithubMock, :rate_limit, &GithubMock.rate_limit/1)
    Hammox.stub(ClientFakeGithubMock, :repo_issues, &GithubMock.repo_issues/3)
    Hammox.stub(ClientFakeGithubMock, :repo_contributors, &GithubMock.repo_contributors/3)
    Hammox.stub(ClientFakeGithubMock, :user, &GithubMock.user/2)

    :ok
  end

  describe "limit_reached?/1" do
    test "when the token is valid, returns ok" do
      webhook = insert(:webhook, repository_token: "token")

      assert {:ok, 4997} = Providers.limit_reached(webhook)
    end

    test "when the token is nil, returns error" do
      webhook = insert(:webhook, repository_token: nil)

      assert {:error, 0} = Providers.limit_reached(webhook)
    end

    test "when the token is invalid, returns error" do
      webhook = insert(:webhook, repository_token: "invalid")

      assert {:error, :timeout} = Providers.limit_reached(webhook)
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
                 %Response.Contributor{
                   name: "octocat",
                   qtd_commits: 32,
                   user: %Response.User{
                     avatar_url: nil,
                     company: nil,
                     email: nil,
                     login: "octocat",
                     name: nil,
                     url: nil
                   }
                 }
               ]
             } = Providers.get_repo(webhook)
    end

    test "when the contributors is nil, return empty contributors response" do
      repository = insert(:repository, name: "empty_contributors_repo")
      webhook = insert(:webhook, repository: repository)

      assert %Response.Repository{
               user: "swap",
               repository: "empty_contributors_repo",
               issues: [
                 %{
                   author: "octocat",
                   labels: [%{description: "Something isn't working", name: "bug"}],
                   title: "Found a bug"
                 }
               ],
               contributors: []
             } = Providers.get_repo(webhook)
    end

    test "when user does not exist in cache, returns user from request" do
      :ets.delete(Swap, "users:octocat")

      repository = insert(:repository, name: "valid_repo")
      webhook = insert(:webhook, repository: repository)

      refute Cache.get("users:octocat")

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
                 %Response.Contributor{
                   name: "octocat",
                   qtd_commits: 32,
                   user: %Response.User{
                     avatar_url: nil,
                     company: nil,
                     email: nil,
                     login: "octocat",
                     name: nil,
                     url: nil
                   }
                 }
               ]
             } = Providers.get_repo(webhook)

      assert %Response.User{} = Cache.get("users:octocat")
    end

    test "when user already exists in cache, returns user from cache" do
      key = "users:octocat"

      :ets.delete(Swap, key)

      user = %Response.User{
        avatar_url: nil,
        company: nil,
        email: nil,
        login: "octocat",
        name: nil,
        url: nil
      }

      Cache.set(key, user)

      repository = insert(:repository, name: "valid_repo")
      webhook = insert(:webhook, repository: repository)

      assert %Response.User{} = Cache.get("users:octocat")

      %Response.User{
        login: "robertov8",
        url: "https://api.github.com/users/robertov8",
        name: "Roberto Ribeiro",
        avatar_url: "https://avatars.githubusercontent.com/u/5904702?v=4",
        company: nil,
        email: nil
      }

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
                 %Response.Contributor{
                   name: "octocat",
                   user: %Response.User{
                     avatar_url: nil,
                     company: nil,
                     email: nil,
                     login: "octocat",
                     name: nil,
                     url: nil
                   },
                   qtd_commits: 32
                 }
               ]
             } = Providers.get_repo(webhook)

      assert %Response.User{} = Cache.get("users:octocat")
    end

    test "when the repository is invalid, returns nil" do
      repository = insert(:repository, name: "invalid_repo")
      webhook = insert(:webhook, repository: repository)

      refute Providers.get_repo(webhook)
    end
  end
end
