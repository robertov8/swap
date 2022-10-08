defmodule SwapWeb.WebhookController do
  use SwapWeb, :controller

  alias Swap.Repositories
  alias Swap.Repositories.Repository
  alias Swap.Webhooks
  alias Swap.Webhooks.Webhook
  alias SwapWeb.Payload.WebhookPayload

  action_fallback SwapWeb.FallbackController

  def index(conn, _params) do
    webhooks = Webhooks.list_webhooks()
    render(conn, "index.json", webhooks: webhooks)
  end

  def create(conn, params) do
    with {:ok, payload} <- WebhookPayload.create_from_params(params),
         {:ok, %Repository{id: repository_id}} <- Repositories.get_or_create_repository(payload),
         payload <- Map.put(payload, :repository_id, repository_id),
         {:ok, %Webhook{} = webhook} <- Webhooks.create_webhook(payload) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.webhook_path(conn, :show, webhook))
      |> render("show.json", webhook: webhook)
    end
  end

  def show(conn, %{"id" => id}) do
    with %Webhook{} = webhook <- Webhooks.get_webhook(id) do
      render(conn, "show.json", webhook: webhook)
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Webhook{} = webhook <- Webhooks.get_webhook(id),
         {:ok, %Webhook{}} <- Webhooks.delete_webhook(webhook) do
      send_resp(conn, :no_content, "")
    end
  end
end
