defmodule Swap.Workers.ScheduleWebhooksWorkerTest do
  @moduledoc false

  use Swap.DataCase
  use Oban.Testing, repo: Swap.Repo, prefix: "jobs"

  alias Swap.Workers.ScheduleWebhooksWorker

  test "schedule all webhooks" do
    [webhook1, webhook2] = insert_list(2, :webhook)

    assert {:ok, [webhook_job1, webhook_job2]} = perform_job(ScheduleWebhooksWorker, %{})

    assert webhook1.id == webhook_job1.id
    assert webhook2.id == webhook_job2.id
  end
end
