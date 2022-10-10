defmodule Swap.Workers.RepositoryStoriesWorker do
  @moduledoc false

  use Oban.Worker,
    queue: :repository_stories,
    max_attempts: 2

  require Logger

  alias Oban.Job
  alias Swap.Providers
  alias Swap.Providers.Response, as: ProviderResponse
  alias Swap.Repositories
  alias Swap.Webhooks
  alias Swap.Webhooks.Webhook

  @impl true
  def perform(%Job{args: %{"webhook_id" => webhook_id}}) do
    case Webhooks.get_webhook(webhook_id) do
      %Webhook{repository: repository} = webhook ->
        repository.id
        |> count_last_hour_repository_stories()
        |> do_perform(webhook)

      nil ->
        {:cancel, :not_found}
    end
  end

  defp do_perform(0, %Webhook{repository: repository} = webhook) do
    with {:ok, _remaining} <- Providers.limit_reached(webhook),
         %ProviderResponse.Repository{} = response <- Providers.get_repo(webhook) do
      Repositories.create_repository_story(%{
        repository_id: repository.id,
        data: Map.from_struct(response)
      })
    else
      nil ->
        {:cancel, :invalid_response}

      {:error, reason} ->
        Swap.Notifications.create_notification(%{
          status: "500",
          response: %{message: "invalid token or limit reached", reason: "#{inspect(reason)}"},
          webhook_id: webhook.id
        })

        schedule_job(webhook.id, Mix.env())
    end
  end

  defp do_perform(_count_last_hour_repository_stories, _webhook), do: {:ok, :updated}

  defp count_last_hour_repository_stories(repository_id) do
    end_date = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    start_date = NaiveDateTime.add(end_date, -1, :hour)

    [repository_id: repository_id, inserted_at: [start_date, end_date]]
    |> Repositories.list_repository_stories()
    |> Enum.count()
  end

  defp schedule_job(_webhook_id, :test), do: {:ok, :rescheduled}

  # coveralls-ignore-start
  defp schedule_job(webhook_id, _env) do
    %{webhook_id: webhook_id}
    |> new(schedule_in: {1, :hour})
    |> Oban.insert()

    {:ok, :rescheduled}
  end
end
