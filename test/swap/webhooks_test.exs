defmodule Swap.WebhooksTest do
  @moduledoc false

  use Swap.DataCase

  import Swap.Factory

  alias Swap.Webhooks

  describe "webhooks" do
    alias Swap.Webhooks.Webhook

    test "list_webhooks/0 returns all webhooks" do
      %{id: id, target: target, repository_id: repository_id} = insert(:webhook)

      response = Webhooks.list_webhooks()

      assert [
               %Webhook{
                 id: ^id,
                 target: ^target,
                 repository_id: ^repository_id
               }
             ] = response
    end

    test "get_webhook/1 returns the webhook with given id" do
      %{id: id, target: target, repository_id: repository_id} = insert(:webhook)

      response = Webhooks.get_webhook(id)

      assert %Webhook{
               id: ^id,
               target: ^target,
               repository_id: ^repository_id
             } = response
    end

    test "create_webhook/1 with valid data creates a webhook" do
      repository = insert(:repository)
      valid_attrs = %{target: "some target", repository_id: repository.id}

      assert {:ok, %Webhook{} = webhook} = Webhooks.create_webhook(valid_attrs)
      assert webhook.target == "some target"
    end

    test "create_webhook/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Webhooks.create_webhook(%{target: nil})
    end

    test "delete_webhook/1 deletes the webhook" do
      webhook = insert(:webhook)
      assert {:ok, %Webhook{}} = Webhooks.delete_webhook(webhook)
      refute Webhooks.get_webhook(webhook.id)
    end
  end
end
