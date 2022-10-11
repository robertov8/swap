defmodule SwapWeb.NotificationController do
  use SwapWeb, :controller

  alias Swap.Notifications
  alias Swap.Notifications.Notification

  action_fallback SwapWeb.FallbackController

  def index(conn, %{"webhook_id" => webhook_id}) do
    notifications = Notifications.list_notifications(webhook_id: webhook_id)
    render(conn, "index.json", notifications: notifications)
  end

  def show(conn, %{"webhook_id" => webhook_id, "id" => id}) do
    filters = [webhook_id: webhook_id, id: id]

    with %Notification{} = notification <- Notifications.get_notification_by(filters) do
      render(conn, "show.json", notification: notification)
    end
  end
end
