defmodule Swap.Webhooks do
  @moduledoc """
  The Webhooks context.
  """

  import Ecto.Query, warn: false

  alias Swap.Notifications
  alias Swap.Repo
  alias Swap.Repositories
  alias Swap.Repositories.RepositoryStory
  alias Swap.Webhooks.{Webhook, WebhookQuery}
  alias Swap.Workers.WebhooksWorker
  alias Utils.HTTPClient

  @type notification_webhook_response ::
          {:ok, String.t()} | {:cancel, :invalid_url | :not_found | String.t()}

  @seconds 10

  @doc """
  Returns the list of webhooks.

  ## Examples

      iex> list_webhooks()
      [%Webhook{}, ...]
      iex>
      iex> list_webhooks(sort_repository_token: :asc)
      [%Webhook{}, ...]
      iex>
      iex> page = 1
      iex> per_page = 10
      iex> list_webhooks(paginate: [page, per_page])
      [%Webhook{}, ...]

  """
  def list_webhooks(filters \\ []) do
    filters
    |> Enum.reduce(Webhook, fn filter, query ->
      case filter do
        {:sort_repository_token, direction} ->
          WebhookQuery.sort_repository_token(query, direction)

        {:paginate, [page, per_page]} ->
          WebhookQuery.with_paginate(page, per_page)

        _ ->
          query
      end
    end)
    |> preload(:repository)
    |> Repo.all()
  end

  @spec count_webhooks :: non_neg_integer()
  def count_webhooks do
    Webhook
    |> select(fragment("COUNT(*)"))
    |> Repo.one()
  end

  @doc """
  Gets a single webhook.

  ## Examples

      iex> get_webhook!(123)
      %Webhook{}

      iex> get_webhook!(456)
      nil

  """
  def get_webhook(id) do
    Webhook
    |> preload(:repository)
    |> Repo.get(id)
  end

  @doc """
  Creates a webhook.

  ## Examples

      iex> create_webhook(%{field: value})
      {:ok, %Webhook{}}

      iex> create_webhook(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_webhook(attrs \\ %{}) do
    %Webhook{}
    |> Webhook.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, webhook} -> {:ok, Repo.preload(webhook, :repository)}
      error -> error
    end
  end

  @doc """
  Deletes a webhook.

  ## Examples

      iex> delete_webhook(webhook)
      {:ok, %Webhook{}}

      iex> delete_webhook(webhook)
      {:error, %Ecto.Changeset{}}

  """
  def delete_webhook(%Webhook{} = webhook) do
    Repo.delete(webhook)
  end

  @spec schedule_webhooks_job(opts :: Keyword.t() | nil) ::
          {:ok, [{:per_page, integer} | {:total, integer}]}
  def schedule_webhooks_job(opts \\ []) do
    per_page = Keyword.get(opts, :per_page, 2)
    total = div(count_webhooks(), per_page)

    for page <- 1..total do
      [paginate: [page, per_page]]
      |> list_webhooks()
      |> Enum.each(&schedule_job({&1, page}, Mix.env()))
    end

    {:ok, [total: total, per_page: per_page]}
  end

  defp schedule_job({webhook_id, _index}, :test), do: webhook_id

  # coveralls-ignore-start
  defp schedule_job({webhook, index}, _env) do
    %{webhook_id: webhook.id}
    |> WebhooksWorker.new(schedule_in: {index * @seconds, :seconds})
    |> Oban.insert()
  end

  # coveralls-ignore-stop

  @spec notification_webhook_job(id :: Ecto.UUID.t()) :: notification_webhook_response()
  def notification_webhook_job(id) do
    with %Webhook{} = webhook <- get_webhook(id),
         %RepositoryStory{data: data} <- get_last_repository_story(webhook) do
      make_post_request(webhook, data)
    else
      nil -> {:cancel, :not_found}
    end
  end

  defp make_post_request(%Webhook{target: nil}, _data), do: {:cancel, :invalid_url}

  defp make_post_request(%Webhook{target: target} = webhook, data) do
    target
    |> HTTPClient.make_post_request(data)
    |> create_notification(webhook)
  end

  defp create_notification({:ok, status, _body}, %Webhook{id: webhook_id}) do
    Notifications.create_notification(%{status: "#{status}", webhook_id: webhook_id})

    {:ok, "status: #{status}"}
  end

  defp create_notification({:error, status, body}, %Webhook{id: webhook_id}) do
    Notifications.create_notification(%{
      status: "#{status}",
      response: %{data: inspect(body)},
      webhook_id: webhook_id
    })

    {:cancel, "status: #{status}"}
  end

  defp get_last_repository_story(webhook) do
    yesterday = Date.utc_today() |> Date.add(-1)

    start_date = NaiveDateTime.new!(yesterday, ~T[00:00:00])
    end_date = NaiveDateTime.new!(yesterday, ~T[23:59:59])

    Repositories.get_repository_story_by(
      repository_id: webhook.repository_id,
      inserted_at: [start_date, end_date]
    )
  end
end
