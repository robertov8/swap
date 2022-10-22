defmodule Swap.Workers.ScheduleWebhooksWorkerTest do
  @moduledoc false

  use Swap.DataCase
  use Oban.Testing, repo: Swap.Repo, prefix: "jobs"

  alias Swap.Workers.ScheduleWebhooksWorker

  test "schedule all webhooks" do
    insert_list(10, :webhook)

    assert {:ok, [total: 1, per_page: 10]} = perform_job(ScheduleWebhooksWorker, %{})
  end
end
