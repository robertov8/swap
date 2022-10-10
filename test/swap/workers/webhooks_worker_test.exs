defmodule Swap.Workers.WebhooksWorkerTest do
  @moduledoc false

  use Swap.DataCase
  use Oban.Testing, repo: Swap.Repo, prefix: "jobs"

  import Tesla.Mock
  import ExUnit.CaptureLog

  alias Swap.Notifications.Notification
  alias Swap.Workers.WebhooksWorker

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
    assert {:cancel, :not_found} = perform_job(WebhooksWorker, %{webhook_id: webhook_id})
  end

  test "when there is no log history to be sent yesterday, returns not_found" do
    webhook = insert(:webhook)

    assert {:cancel, :not_found} = perform_job(WebhooksWorker, %{webhook_id: webhook.id})
  end

  test "when webhook has no url, returns invalid_url" do
    yesterday = NaiveDateTime.utc_now() |> NaiveDateTime.add(-1, :day)

    repository_story = insert(:repository_story, inserted_at: yesterday, updated_at: yesterday)
    webhook = insert(:webhook, target: nil, repository: repository_story.repository)

    assert {:cancel, :invalid_url} = perform_job(WebhooksWorker, %{webhook_id: webhook.id})
  end

  test "when http client response is valid, returns success notification" do
    yesterday = NaiveDateTime.utc_now() |> NaiveDateTime.add(-1, :day)

    repository_story = insert(:repository_story, inserted_at: yesterday, updated_at: yesterday)

    webhook =
      insert(:webhook,
        target: "http://swap.com.br/webhook",
        repository: repository_story.repository
      )

    assert {:ok, "status: 200"} = perform_job(WebhooksWorker, %{webhook_id: webhook.id})
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
        assert {:cancel, "status: 500"} = perform_job(WebhooksWorker, %{webhook_id: webhook.id})
      end)

    assert log =~ "status: 500"
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
