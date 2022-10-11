defmodule SwapWeb.NotificationView do
  use SwapWeb, :view
  alias SwapWeb.NotificationView

  def render("index.json", %{notifications: notifications}) do
    %{data: render_many(notifications, NotificationView, "notification.json")}
  end

  def render("show.json", %{notification: notification}) do
    %{data: render_one(notification, NotificationView, "notification.json")}
  end

  def render("notification.json", %{notification: notification}) do
    %{
      id: notification.id,
      status: notification.status,
      response: notification.response,
      webhook_id: notification.webhook_id,
      inserted_at: notification.inserted_at,
      updated_at: notification.updated_at
    }
  end
end
