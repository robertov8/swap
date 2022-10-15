defmodule Swap.Workers.ScheduleWebhooksWorker do
  @moduledoc false

  use Oban.Worker,
    queue: :schedule_webhooks,
    max_attempts: 1

  require Logger

  alias Swap.Webhooks

  @impl true
  def perform(_job) do
    Webhooks.schedule_webhooks_job()

    :ok
  end
end
