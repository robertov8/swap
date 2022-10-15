defmodule Swap.Webhooks do
  @moduledoc """
  The Webhooks context.
  """

  import Ecto.Query, warn: false
  alias Swap.Repo

  alias Swap.Webhooks.{Webhook, WebhookQuery}
  alias Swap.Workers.WebhooksWorker

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
end
