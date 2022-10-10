defmodule Swap.Workers.ScheduleWebhooksWorker do
  @moduledoc false

  use Oban.Worker,
    queue: :schedule_webhooks,
    max_attempts: 1

  require Logger

  alias Swap.Webhooks
  alias Swap.Workers.WebhooksWorker

  @seconds 10

  @impl true
  def perform(_job) do
    Webhooks.list_webhooks(order_repository_token: :asc)
    |> Enum.with_index()
    |> Enum.each(&schedule_job/1)

    :ok
  end

  defp schedule_job({webhook, index}) do
    %{webhook_id: webhook.id}
    |> WebhooksWorker.new(schedule_in: {index * @seconds, :seconds})
    |> Oban.insert()
  end
end
