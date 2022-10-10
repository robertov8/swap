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
        :ok
    end
  end

  defp do_perform(0, %Webhook{repository: repository} = webhook) do
    with false <- Providers.limit_reached?(webhook),
         %ProviderResponse.Repository{} = response <- Providers.get_repo(webhook) do
      Repositories.create_repository_story(%{
        repository_id: repository.id,
        data: Map.from_struct(response)
      })
    else
      true ->
        %{webhook_id: webhook.id}
        |> new(schedule_in: {1, :hour})
        |> Oban.insert()

      nil ->
        {:cancel, :invalid_response}
    end
  end

  defp do_perform(_count_last_hour_repository_stories, _webhook), do: :ok

  defp count_last_hour_repository_stories(repository_id) do
    end_date = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    start_date = NaiveDateTime.add(end_date, -1, :hour)

    [repository_id: repository_id, inserted_at: [start_date, end_date]]
    |> Repositories.list_repository_stories()
    |> Enum.count()
  end
end
