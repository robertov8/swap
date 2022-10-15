defmodule Swap.WebhooksTest do
  @moduledoc false

  use Swap.DataCase

  import Swap.Factory

  alias Swap.Webhooks

  describe "webhooks" do
    setup do
      {:ok, %{webhook: insert(:webhook)}}
    end

    alias Swap.Webhooks.Webhook

    test "list_webhooks/0 returns all webhooks", %{webhook: webhook} do
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

    test "list_webhooks/0 returns all webhooks sort sort_repository_token" do
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

    test "list_webhooks/0 returns all webhooks paginate" do
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

    test "get_webhook/1 returns the webhook with given id", %{webhook: webhook} do
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

    test "count_webhooks/0 return total webhooks" do
      assert 1 == Webhooks.count_webhooks()

      insert(:webhook)

      assert 2 == Webhooks.count_webhooks()
    end

    test "create_webhook/1 with valid data creates a webhook" do
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

    test "create_webhook/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{} = changeset} = Webhooks.create_webhook(%{target: nil})

      assert "can't be blank" in errors_on(changeset).target
      assert "can't be blank" in errors_on(changeset).repository_id
    end

    test "delete_webhook/1 deletes the webhook" do
      webhook = insert(:webhook)
      assert {:ok, %Webhook{}} = Webhooks.delete_webhook(webhook)
      refute Webhooks.get_webhook(webhook.id)
    end

    test "schedule_webhooks_job/1 schedule all webhooks" do
      insert_list(4, :webhook)

      assert {:ok, [total: 2, per_page: 2]} = Webhooks.schedule_webhooks_job(per_page: 2)
    end
  end
end
