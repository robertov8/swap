defmodule Swap.Workers.RepositoryStoriesWorkerTest do
  @moduledoc false

  use Swap.DataCase
  use Oban.Testing, repo: Swap.Repo, prefix: "jobs"

  alias Swap.Clients.Github.Mock, as: GithubMock
  alias Swap.Repositories.RepositoryStory
  alias Swap.Workers.RepositoryStoriesWorker

  setup do
    Hammox.stub(ClientFakeGithubMock, :rate_limit, &GithubMock.rate_limit/1)
    Hammox.stub(ClientFakeGithubMock, :repo_issues, &GithubMock.repo_issues/3)
    Hammox.stub(ClientFakeGithubMock, :repo_contributors, &GithubMock.repo_contributors/3)
    Hammox.stub(ClientFakeGithubMock, :user, &GithubMock.user/2)

    :ok
  end

  test "when webhook doesn't exist, returns not_found" do
    webhook_id = Ecto.UUID.generate()

    assert {:cancel, :not_found} = perform_job(RepositoryStoriesWorker, %{webhook_id: webhook_id})
    refute Repo.exists?(RepositoryStory)
  end

  test "when it reaches the limit of requests, returns rescheduled" do
    webhook = insert(:webhook, repository_token: nil)

    assert {:ok, :rescheduled} = perform_job(RepositoryStoriesWorker, %{webhook_id: webhook.id})

    assert Repo.exists?(Swap.Notifications.Notification)
    refute Repo.exists?(RepositoryStory)
  end

  test "when the repository was invalid, returns invalid_response" do
    repository = insert(:repository, name: "invalid_repo")
    webhook = insert(:webhook, repository_token: "token", repository: repository)

    assert {:cancel, :invalid_response} =
             perform_job(RepositoryStoriesWorker, %{webhook_id: webhook.id})

    refute Repo.exists?(RepositoryStory)
  end

  test "when have histories in the last one, returns repository_story" do
    repository = insert(:repository, name: "valid_repo")
    webhook = insert(:webhook, repository_token: "token", repository: repository)

    assert {:ok, %RepositoryStory{}} =
             perform_job(RepositoryStoriesWorker, %{webhook_id: webhook.id})
  end
end
