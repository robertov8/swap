defmodule SwapWeb.NotificationControllerTest do
  @moduledoc false

  use SwapWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all notifications", %{conn: conn} do
      conn = get(conn, Routes.webhook_notification_path(conn, :index, Ecto.UUID.generate()))
      assert json_response(conn, 200)["data"] == []

      %{id: id, webhook_id: webhook_id} = insert(:notification)

      conn = get(conn, Routes.webhook_notification_path(conn, :index, webhook_id))

      assert [
               %{
                 "id" => ^id,
                 "webhook_id" => ^webhook_id
               }
             ] = json_response(conn, 200)["data"]
    end
  end

  describe "show notification" do
    test "renders notification when id is valid", %{conn: conn} do
      %{id: id, webhook_id: webhook_id} = insert(:notification)

      conn = get(conn, Routes.webhook_notification_path(conn, :show, webhook_id, id))

      assert %{
               "id" => ^id,
               "webhook_id" => ^webhook_id
             } = json_response(conn, 200)["data"]
    end
  end
end
