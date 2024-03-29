defmodule Swap.NotificationsTest do
  @moduledoc false

  use Swap.DataCase

  alias Swap.Notifications

  describe "notifications" do
    alias Swap.Notifications.Notification

    @invalid_attrs %{response: nil, status: nil}

    test "list_notifications/0 returns all notifications" do
      %{id: notification_id, webhook_id: webhook_id} = insert(:notification)

      assert [
               %Swap.Notifications.Notification{
                 id: ^notification_id,
                 response: %{"status" => "ok"},
                 status: "200",
                 webhook_id: ^webhook_id
               }
             ] = Notifications.list_notifications()
    end

    test "list_notifications/0 returns all stories by filter" do
      insert(:notification)

      %{id: notification_id, webhook_id: webhook_id} = insert(:notification)

      assert [
               %Swap.Notifications.Notification{
                 id: ^notification_id,
                 response: %{"status" => "ok"},
                 status: "200",
                 webhook_id: ^webhook_id
               }
             ] = Notifications.list_notifications(webhook_id: webhook_id)
    end

    test "get_notification_by/1 returns the notification with given filter" do
      %{id: notification_id, webhook_id: webhook_id} = insert(:notification)

      refute Notifications.get_notification_by()
      refute Notifications.get_notification_by([])

      assert %Swap.Notifications.Notification{
               id: ^notification_id,
               response: %{"status" => "ok"},
               status: "200",
               webhook_id: ^webhook_id
             } = Notifications.get_notification_by(id: notification_id)

      assert %Swap.Notifications.Notification{
               id: ^notification_id,
               response: %{"status" => "ok"},
               status: "200",
               webhook_id: ^webhook_id
             } = Notifications.get_notification_by(webhook_id: webhook_id)
    end

    test "create_notification/1 with valid data creates a notification" do
      webhook = insert(:webhook)
      valid_attrs = %{response: %{}, status: "some status", webhook_id: webhook.id}

      assert {:ok, %Notification{} = notification} =
               Notifications.create_notification(valid_attrs)

      assert notification.response == %{}
      assert notification.status == "some status"
    end

    test "create_notification/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Notifications.create_notification(@invalid_attrs)

      assert "can't be blank" in errors_on(changeset).status
      assert "can't be blank" in errors_on(changeset).webhook_id
    end
  end
end
