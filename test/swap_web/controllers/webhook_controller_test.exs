defmodule SwapWeb.WebhookControllerTest do
  @moduledoc false

  use SwapWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all webhooks", %{conn: conn} do
      conn = get(conn, Routes.webhook_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create webhook" do
    test "renders webhook when data is valid", %{conn: conn} do
      %{id: repository_id, name: repository_name, owner: repository_owner} = insert(:repository)

      valid_attrs = %{
        target: "http://www.swap.com.br",
        repository_id: repository_id,
        repository_token: "token"
      }

      conn = post(conn, Routes.webhook_path(conn, :create), valid_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.webhook_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "repository" => %{
                 "id" => ^repository_id,
                 "name" => ^repository_name,
                 "owner" => ^repository_owner
               },
               "target" => "http://www.swap.com.br",
               "inserted_at" => _inserted_at,
               "updated_at" => _updated_at
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.webhook_path(conn, :create), %{target: nil})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when repository_id not found", %{conn: conn} do
      conn =
        post(conn, Routes.webhook_path(conn, :create), %{
          target: "http://www.swap.com.br",
          repository_id: Ecto.UUID.generate(),
          repository_token: "token"
        })

      assert json_response(conn, 404)["errors"] != %{}
    end
  end

  describe "delete webhook" do
    setup [:create_webhook]

    test "deletes chosen webhook", %{conn: conn, webhook: webhook} do
      conn = delete(conn, Routes.webhook_path(conn, :delete, webhook))
      assert response(conn, 204)

      conn = get(conn, Routes.webhook_path(conn, :show, webhook))
      assert response(conn, 404)
    end
  end

  defp create_webhook(_), do: %{webhook: insert(:webhook)}
end
