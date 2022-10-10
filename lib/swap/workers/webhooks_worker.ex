defmodule Swap.Workers.WebhooksWorker do
  @moduledoc false

  use Oban.Worker,
    queue: :schedule_webhooks,
    max_attempts: 1

  require Logger

  alias Oban.Job
  alias Swap.Repositories
  alias Swap.Repositories.RepositoryStory
  alias Swap.Utils.HttpClient
  alias Swap.Webhooks
  alias Swap.Webhooks.Webhook

  @impl true
  def perform(%Job{args: %{"webhook_id" => webhook_id}}) do
    with %Webhook{} = webhook <- Webhooks.get_webhook(webhook_id),
         %RepositoryStory{data: data} <- get_last_repository_story(webhook) do
      make_post_request(webhook, data)
    end
  end

  defp make_post_request(%Webhook{target: nil}, _data), do: :ok

  defp make_post_request(%Webhook{target: target} = webhook, data) do
    target
    |> HttpClient.make_post_request(data)
    |> create_notification(webhook)
  end

  defp create_notification({:ok, status, _body}, %Webhook{id: webhook_id}) do
    Swap.Notifications.create_notification(%{status: "#{status}", webhook_id: webhook_id})

    {:ok, "status: #{status}"}
  end

  defp create_notification({:error, status, body}, %Webhook{id: webhook_id}) do
    Swap.Notifications.create_notification(%{
      status: "#{status}",
      response: %{data: inspect(body)},
      webhook_id: webhook_id
    })

    {:cancel, "status: #{status}"}
  end

  def get_last_repository_story(webhook) do
    yesterday = Date.utc_today() |> Date.add(-1)

    start_date = NaiveDateTime.new!(yesterday, ~T[00:00:00])
    end_date = NaiveDateTime.new!(yesterday, ~T[23:59:59])

    Repositories.get_repository_story_by(
      repository_id: webhook.repository_id,
      inserted_at: [start_date, end_date]
    )
  end
end
