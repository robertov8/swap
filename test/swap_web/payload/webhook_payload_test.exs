defmodule SwapWeb.Payload.WebhookPayloadTest do
  @moduledoc false

  use Swap.DataCase

  alias Ecto.Changeset
  alias SwapWeb.Payload.WebhookPayload

  describe "create_from_params/1" do
    setup do
      params = %{
        "target" => "http://www.swap.com.br",
        "repository_id" => Ecto.UUID.generate(),
        "repo" => nil,
        "owner" => nil,
        "repository_token" => "token",
        "repository_provider" => "github"
      }

      {:ok, %{params: params}}
    end

    test "when all parameters are valid, returns valid payload", %{params: params} do
      assert {:ok, payload} = WebhookPayload.create_from_params(params)

      assert payload.target == params["target"]
      assert payload.repository_id == params["repository_id"]
      refute payload.repo
      refute payload.owner
      assert payload.repository_token == params["repository_token"]
      assert payload.repository_provider == params["repository_provider"]

      params = %{params | "repository_id" => nil, "repo" => "swap", "owner" => "swap"}

      assert {:ok, payload} = WebhookPayload.create_from_params(params)

      assert payload.target == params["target"]
      refute payload.repository_id
      assert payload.repo == params["repo"]
      assert payload.owner == params["owner"]
      assert payload.repository_token == params["repository_token"]
      assert payload.repository_provider == params["repository_provider"]
    end

    test "when target is invalid, returns an error", %{params: params} do
      params = %{params | "target" => "swap.com.br"}

      assert {:error, %Changeset{} = changeset} = WebhookPayload.create_from_params(params)

      assert %Changeset{valid?: false} = changeset
      assert "is not a valid url" in errors_on(changeset).target
    end

    test "when repository_provider is invalid, returns an error", %{params: params} do
      params = %{params | "repository_provider" => "gitlab"}

      assert {:error, %Changeset{} = changeset} = WebhookPayload.create_from_params(params)

      assert %Changeset{valid?: false} = changeset
      assert "is invalid" in errors_on(changeset).repository_provider
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
