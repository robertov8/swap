defmodule Swap.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Swap.Repo

  def repository_factory do
    %Swap.Repositories.Repository{
      name: Faker.Internet.domain_word(),
      owner: "swap"
    }
  end

  def webhook_factory do
    %Swap.Webhooks.Webhook{
      target: Faker.Internet.url(),
      repository: insert(:repository)
    }
  end
end
