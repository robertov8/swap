defmodule Swap.Clients.Github.HttpTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import Tesla.Mock

  alias Swap.Clients.Github.{Http, Response}

  describe "repo_issues/2" do
    setup do
      mock(fn
        %{method: :get, url: "https://api.github.com/repos/swap/valid_repo/issues"} ->
          setup_http_success(:issues)

        %{method: :get, url: "https://api.github.com/repos/swap/123/issues"} ->
          setup_http_unprocessable_entity()

        %{method: :get, url: "https://api.github.com/repos/swap/resource_not_found/issues"} ->
          setup_http_invalid_request(404)

        %{method: :get, url: "https://api.github.com/repos/swap/spammed/issues"} ->
          setup_http_invalid_request(422)
      end)
    end

    test "when the repository is valid, returns success" do
      response = Http.repo_issues("swap", "valid_repo")

      expected_response =
        {:ok,
         [
           %Response.Issue{
             id: 1,
             title: "Found a bug",
             author: "octocat",
             labels: [%{"description" => "Something isn't working", "name" => "bug"}]
           }
         ]}

      assert expected_response == response
    end

    test "when the repository does not exist, returns an error" do
      response = Http.repo_issues("swap", "123")

      expected_response = {:error, %Response.Error{status: nil, reason: "Not Found"}}

      assert expected_response == response
    end

    test "when the repository Resource not found, returns an error" do
      response = Http.repo_issues("swap", "resource_not_found")

      expected_response = {:error, %Response.Error{reason: "Resource not found", status: 404}}

      assert expected_response == response
    end

    test "when the repository Validation failed, or the endpoint has been spammed, returns an error" do
      response = Http.repo_issues("swap", "spammed")

      expected_response =
        {:error,
         %Response.Error{
           reason: "Validation failed, or spammed.",
           status: 422
         }}

      assert expected_response == response
    end
  end

  describe "repo_contributors/2" do
    setup do
      mock(fn
        %{method: :get, url: "https://api.github.com/repos/swap/valid_repo/contributors"} ->
          setup_http_success(:contributors)

        %{method: :get, url: "https://api.github.com/repos/swap/empty/contributors"} ->
          setup_http_invalid_request(204)

        %{method: :get, url: "https://api.github.com/repos/swap/resource_not_found/contributors"} ->
          setup_http_invalid_request(404)

        %{method: :get, url: "https://api.github.com/repos/swap/forbidden/contributors"} ->
          setup_http_invalid_request(403)
      end)
    end

    test "when the repository is valid, returns success" do
      response = Http.repo_contributors("swap", "valid_repo")

      expected_response =
        {:ok,
         [
           %Swap.Clients.Github.Response.Contributor{
             id: 1,
             contributions: 32,
             login: "octocat",
             user: "https://api.github.com/users/octocat"
           }
         ]}

      assert expected_response == response
    end

    test "when the repository empty, returns an error" do
      response = Http.repo_contributors("swap", "empty")

      expected_response =
        {:error,
         %Swap.Clients.Github.Response.Error{
           reason: "Response if repository is empty",
           status: 204
         }}

      assert expected_response == response
    end

    test "when the repository Resource not found, returns an error" do
      response = Http.repo_contributors("swap", "resource_not_found")

      expected_response = {:error, %Response.Error{reason: "Resource not found", status: 404}}

      assert expected_response == response
    end

    test "when the repository Forbidden, returns an error" do
      response = Http.repo_contributors("swap", "forbidden")

      expected_response =
        {:error,
         %Response.Error{
           reason: "Forbidden",
           status: 403
         }}

      assert expected_response == response
    end
  end

  defp setup_http_invalid_request(status \\ 400) do
    {:error,
     %Tesla.Env{
       body: "",
       method: :get,
       opts: [],
       query: [],
       status: status,
       url: "https://api.github.com"
     }}
  end

  defp setup_http_unprocessable_entity do
    build_http(%{
      "documentation_url" =>
        "https://docs.github.com/rest/reference/issues#list-repository-issues",
      "message" => "Not Found"
    })
  end

  defp setup_http_success(:contributors) do
    build_http([
      %{
        "login" => "octocat",
        "id" => 1,
        "url" => "https://api.github.com/users/octocat",
        "site_admin" => false,
        "contributions" => 32
      }
    ])
  end

  defp setup_http_success(:issues) do
    build_http([
      %{
        "id" => 1,
        "title" => "Found a bug",
        "user" => %{
          "login" => "octocat"
        },
        "labels" => [
          %{
            "name" => "bug",
            "description" => "Something isn't working"
          }
        ]
      }
    ])
  end

  defp build_http(body, status \\ 200) do
    {:ok,
     %Tesla.Env{
       headers: [{"Content-Type", "application/json; charset=utf-8"}],
       body: body,
       method: :get,
       opts: [],
       query: [],
       status: status,
       url: "https://api.github.com"
     }}
  end
end
