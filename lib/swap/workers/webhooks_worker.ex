defmodule Swap.Workers.WebhooksWorker do
  @moduledoc false

  use Oban.Worker,
    queue: :schedule_webhooks,
    max_attempts: 1

  require Logger

  alias Oban.Job
  alias Swap.Webhooks

  @impl true
  def perform(%Job{args: %{"webhook_id" => webhook_id}}),
    do: Webhooks.notification_webhook_job(webhook_id)
end
