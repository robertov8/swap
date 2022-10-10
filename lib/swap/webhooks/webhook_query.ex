defmodule Swap.Webhooks.WebhookQuery do
  @moduledoc false

  import Ecto.Query

  alias Swap.Webhooks.Webhook

  @spec sort_repository_token(query :: any(), direction :: :asc | :desc) :: Ecto.Query.t()
  def sort_repository_token(query \\ base(), direction)

  def sort_repository_token(query, :asc) do
    order_by(query, asc: :repository_token)
  end

  def sort_repository_token(query, :desc) do
    order_by(query, desc: :repository_token)
  end

  defp base, do: Webhook
end
