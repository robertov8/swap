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
    webhooks =
      Webhooks.list_webhooks(sort_repository_token: :asc)
      |> Enum.with_index()
      |> Enum.map(&schedule_job(&1, Mix.env()))

    {:ok, webhooks}
  end

  defp schedule_job({webhook_id, _index}, :test), do: webhook_id

  # coveralls-ignore-start
  defp schedule_job({webhook, index}, _env) do
    %{webhook_id: webhook.id}
    |> WebhooksWorker.new(schedule_in: {index * @seconds, :seconds})
    |> Oban.insert()
  end
end
