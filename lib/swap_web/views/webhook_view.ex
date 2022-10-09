defmodule SwapWeb.WebhookView do
  use SwapWeb, :view
  alias SwapWeb.WebhookView

  def render("index.json", %{webhooks: webhooks}) do
    %{data: render_many(webhooks, WebhookView, "webhook.json")}
  end

  def render("show.json", %{webhook: webhook}) do
    %{data: render_one(webhook, WebhookView, "webhook.json")}
  end

  def render("webhook.json", %{webhook: webhook}) do
    %{
      id: webhook.id,
      target: webhook.target,
      repository: %{
        id: webhook.repository.id,
        name: webhook.repository.name,
        owner: webhook.repository.owner,
        provider: webhook.repository.provider
      },
      inserted_at: webhook.inserted_at,
      updated_at: webhook.updated_at
    }
  end
end
