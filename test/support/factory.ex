defmodule Swap.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Swap.Repo

  def webhook_factory do
    %Swap.Webhooks.Webhook{
      target: Faker.Internet.url(),
      repository: insert(:repository),
      repository_token: nil
    }
  end

  def repository_factory do
    %Swap.Repositories.Repository{
      name: Faker.Internet.user_name(),
      owner: "swap",
      provider: "github"
    }
  end

  def repository_story_factory do
    %Swap.Repositories.RepositoryStory{
      data: %{
        "user" => "user",
        "repository" => "repository",
        "issue" => [],
        "contributors" => []
      },
      repository: insert(:repository)
    }
  end

  def notification_factory do
    %Swap.Notifications.Notification{
      status: "200",
      response: %{"status" => "ok"},
      webhook: insert(:webhook)
    }
  end
end
