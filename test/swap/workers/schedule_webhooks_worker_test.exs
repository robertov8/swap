defmodule Swap.Workers.ScheduleWebhooksWorkerTest do
  @moduledoc false

  use Swap.DataCase
  use Oban.Testing, repo: Swap.Repo, prefix: "jobs"

  alias Swap.Workers.ScheduleWebhooksWorker

  test "schedule all webhooks" do
    insert_list(2, :webhook)

    assert :ok = perform_job(ScheduleWebhooksWorker, %{})
  end
end
