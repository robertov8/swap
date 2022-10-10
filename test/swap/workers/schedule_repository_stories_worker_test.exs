defmodule Swap.Workers.ScheduleRepositoryStoriesWorkerTest do
  @moduledoc false

  use Swap.DataCase
  use Oban.Testing, repo: Swap.Repo, prefix: "jobs"

  alias Swap.Workers.ScheduleRepositoryStoriesWorker

  test "schedule all webhooks" do
    webhooks1 = insert_list(5, :webhook, repository: insert(:repository, owner: "swap0"))
    webhooks2 = insert_list(5, :webhook, repository: insert(:repository, owner: "swap1"))

    webhooks = webhooks1 ++ webhooks2

    assert {:ok, [webhook_id1, webhook_id2]} = perform_job(ScheduleRepositoryStoriesWorker, %{})

    assert Enum.find(webhooks, fn webhook -> webhook.id == webhook_id1 end)
    assert Enum.find(webhooks, fn webhook -> webhook.id == webhook_id2 end)
  end
end
