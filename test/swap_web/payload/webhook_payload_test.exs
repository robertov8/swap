defmodule SwapWeb.Payload.WebhookPayloadTest do
  @moduledoc false

  use Swap.DataCase

  import Swap.Factory

  alias Ecto.Changeset
  alias SwapWeb.Payload.WebhookPayload

  describe "create_from_params/1" do
    setup do
      repository = insert(:repository)

      params = %{
        "target" => "http://www.swap.com.br",
        "repository_id" => repository.id,
        "repo" => nil,
        "owner" => nil
      }

      {:ok, %{params: params}}
    end

    test "when all parameters are valid, returns valid payload", %{params: params} do
      assert {:ok, payload} = WebhookPayload.create_from_params(params)

      assert payload.target == params["target"]
      assert payload.repository_id == params["repository_id"]
      refute payload.repo
      refute payload.owner

      params = %{params | "repository_id" => nil, "repo" => "swap", "owner" => "swap"}

      assert {:ok, payload} = WebhookPayload.create_from_params(params)

      assert payload.target == params["target"]
      refute payload.repository_id
      assert payload.repo == params["repo"]
      assert payload.owner == params["owner"]
    end

    test "when parameters are invalid, returns an error" do
      assert {:error, %Changeset{} = changeset} = WebhookPayload.create_from_params(%{})

      assert %Changeset{valid?: false} = changeset
      assert "can't be blank" in errors_on(changeset).target
      assert "can't be blank" in errors_on(changeset).repo
      assert "can't be blank" in errors_on(changeset).owner

      assert {:error, %Changeset{} = changeset} =
               WebhookPayload.create_from_params(%{"target" => "swap.com.br"})

      assert %Changeset{valid?: false} = changeset
      assert "is not a valid url" in errors_on(changeset).target
      assert "can't be blank" in errors_on(changeset).repo
      assert "can't be blank" in errors_on(changeset).owner

      assert {:error, %Changeset{} = changeset} =
               WebhookPayload.create_from_params(%{
                 "target" => "http://swap.com.br",
                 "repository_id" => ""
               })

      assert %Changeset{valid?: false} = changeset
      assert "can't be blank" in errors_on(changeset).repository_id
    end
  end
end
