defmodule Swap.Workers.ScheduleRepositoryStoriesWorker do
  @moduledoc false

  use Oban.Worker,
    queue: :schedule_repository_stories,
    max_attempts: 1

  require Logger

  alias Swap.Webhooks
  alias Swap.Workers.RepositoryStoriesWorker

  @seconds 10

  @impl true
  def perform(_job) do
    webhooks =
      Webhooks.list_webhooks(order_repository_token: :asc)
      |> Enum.group_by(& &1.repository.owner, &[&1.repository.name, &1.id])
      |> Enum.map(fn {_owner, [[_repo, webhook_id] | _]} -> webhook_id end)
      |> Enum.with_index()
      |> Enum.map(&schedule_job(&1, Mix.env()))

    {:ok, webhooks}
  end

  defp schedule_job({webhook_id, _index}, :test), do: webhook_id

  # coveralls-ignore-start
  defp schedule_job({webhook_id, index}, _env) do
    %{webhook_id: webhook_id}
    |> RepositoryStoriesWorker.new(schedule_in: {index * @seconds, :seconds})
    |> Oban.insert()
  end
end
