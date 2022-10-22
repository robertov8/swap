defmodule Swap.WebhooksTest do
  @moduledoc false

  use Swap.DataCase

  import Swap.Factory
  import Tesla.Mock
  import ExUnit.CaptureLog

  alias Swap.Notifications.Notification
  alias Swap.Repo
  alias Swap.Webhooks
  alias Swap.Webhooks.Webhook

  setup do
    {:ok, %{webhook: insert(:webhook)}}
  end

  describe "list_webhooks/0" do
    test "returns all webhooks", %{webhook: webhook} do
      %{
        id: id,
        target: target,
        repository_id: repository_id,
        repository: %{id: repository_id, name: repository_name}
      } = webhook

      response = Webhooks.list_webhooks()

      assert [
               %Webhook{
                 id: ^id,
                 target: ^target,
                 repository_id: ^repository_id,
                 repository: %{
                   id: ^repository_id,
                   name: ^repository_name,
                   owner: "swap",
                   provider: :github
                 }
               }
             ] = response
    end

    test "returns all webhooks sort sort_repository_token" do
      insert(:webhook, repository_token: "a")
      insert(:webhook, repository_token: "b")
      insert(:webhook, repository_token: "c")

      response = Webhooks.list_webhooks(sort_repository_token: :asc)

      assert [
               %Webhook{repository_token: "a"},
               %Webhook{repository_token: "b"},
               %Webhook{repository_token: "c"},
               %Webhook{repository_token: nil}
             ] = response

      response = Webhooks.list_webhooks(sort_repository_token: :desc)

      assert [
               %Webhook{repository_token: nil},
               %Webhook{repository_token: "c"},
               %Webhook{repository_token: "b"},
               %Webhook{repository_token: "a"}
             ] = response
    end

    test "returns all webhooks paginate" do
      insert(:webhook, repository_token: "a")
      insert(:webhook, repository_token: "b")
      insert(:webhook, repository_token: "c")

      page = 1
      per_page = 2

      response = Webhooks.list_webhooks(paginate: [page, per_page])

      assert [
               %Webhook{repository_token: nil},
               %Webhook{repository_token: "a"}
             ] = response

      page = 2

      response = Webhooks.list_webhooks(paginate: [page, per_page])

      assert [
               %Webhook{repository_token: "b"},
               %Webhook{repository_token: "c"}
             ] = response
    end
  end

  describe "get_webhook/1" do
    test "returns the webhook with given id", %{webhook: webhook} do
      %{
        id: id,
        target: target,
        repository_id: repository_id,
        repository: %{id: repository_id, name: repository_name}
      } = webhook

      response = Webhooks.get_webhook(id)

      assert %Webhook{
               id: ^id,
               target: ^target,
               repository_id: ^repository_id,
               repository: %{
                 id: ^repository_id,
                 name: ^repository_name,
                 owner: "swap",
                 provider: :github
               }
             } = response
    end
  end

  describe "count_webhooks/0" do
    test "return total webhooks" do
      assert 1 == Webhooks.count_webhooks()

      insert(:webhook)

      assert 2 == Webhooks.count_webhooks()
    end
  end

  describe "create_webhook/1" do
    test "with valid data creates a webhook" do
      %{id: repository_id, name: repository_name} = insert(:repository)
      valid_attrs = %{target: "some target", repository_id: repository_id}

      assert {:ok,
              %Webhook{
                target: "some target",
                repository_id: ^repository_id,
                repository: %{
                  id: ^repository_id,
                  name: ^repository_name,
                  owner: "swap",
                  provider: :github
                }
              }} = Webhooks.create_webhook(valid_attrs)
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{} = changeset} = Webhooks.create_webhook(%{target: nil})

      assert "can't be blank" in errors_on(changeset).target
      assert "can't be blank" in errors_on(changeset).repository_id
    end
  end

  describe "delete_webhook/1" do
    test "deletes the webhook" do
      webhook = insert(:webhook)
      assert {:ok, %Webhook{}} = Webhooks.delete_webhook(webhook)
      refute Webhooks.get_webhook(webhook.id)
    end
  end

  describe "schedule_webhooks_job/1" do
    test "schedule all webhooks" do
      insert_list(4, :webhook)

      assert {:ok, [total: 2, per_page: 2]} = Webhooks.schedule_webhooks_job(per_page: 2)
    end
  end

  describe "notification_webhook_job/1" do
    setup do
      mock(fn
        %{method: :post, url: "http://swap.com.br/webhook"} ->
          setup_http(200, %{"status" => "ok"})

        %{method: :post, url: "http://invalid.com.br/webhook"} ->
          setup_http(500, %{"status" => "error"})
      end)

      :ok
    end

    test "when webhook doesn't exist, returns not_found" do
      webhook_id = Ecto.UUID.generate()

      assert {:cancel, :not_found} = Webhooks.notification_webhook_job(webhook_id)
    end

    test "when there is no log history to be sent yesterday, returns not_found" do
      webhook = insert(:webhook)

      assert {:cancel, :not_found} = Webhooks.notification_webhook_job(webhook.id)
    end

    test "when webhook has no url, returns invalid_url" do
      yesterday = NaiveDateTime.utc_now() |> NaiveDateTime.add(-1, :day)

      repository_story = insert(:repository_story, inserted_at: yesterday, updated_at: yesterday)
      webhook = insert(:webhook, target: nil, repository: repository_story.repository)

      assert {:cancel, :invalid_url} = Webhooks.notification_webhook_job(webhook.id)
    end

    test "when http client response is valid, returns success notification" do
      yesterday = NaiveDateTime.utc_now() |> NaiveDateTime.add(-1, :day)

      repository_story = insert(:repository_story, inserted_at: yesterday, updated_at: yesterday)

      webhook =
        insert(:webhook,
          target: "http://swap.com.br/webhook",
          repository: repository_story.repository
        )

      assert {:ok, "status: 200"} = Webhooks.notification_webhook_job(webhook.id)
      assert Repo.exists?(Notification)
    end

    test "when http client response invalid, returns error notification" do
      yesterday = NaiveDateTime.utc_now() |> NaiveDateTime.add(-1, :day)

      repository_story = insert(:repository_story, inserted_at: yesterday, updated_at: yesterday)

      webhook =
        insert(:webhook,
          target: "http://invalid.com.br/webhook",
          repository: repository_story.repository
        )

      {_result, log} =
        with_log(fn ->
          assert {:cancel, "status: 500"} = Webhooks.notification_webhook_job(webhook.id)
        end)

      assert log =~ "status: 500"
    end
  end

  defp setup_http(status, body) do
    {:ok,
     %Tesla.Env{
       headers: [{"Content-Type", "application/json; charset=utf-8"}],
       body: body,
       method: :get,
       opts: [],
       query: [],
       status: status,
       url: "https://webhook.site"
     }}
  end
end
