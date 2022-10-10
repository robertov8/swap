defmodule Swap.Webhooks.WebhookQuery do
  @moduledoc false

  import Ecto.Query

  alias Swap.Webhooks.Webhook

  def order_repository_token(query \\ base(), direction)

  def order_repository_token(query, :asc) do
    order_by(query, asc: :repository_token)
  end

  def order_repository_token(query, :desc) do
    order_by(query, desc: :repository_token)
  end

  defp base, do: Webhook
end
