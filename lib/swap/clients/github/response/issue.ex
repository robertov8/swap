defmodule Swap.Clients.Github.Response.Issue do
  @moduledoc false

  @behaviour Swap.Clients.Github.Response

  defstruct id: nil, title: nil, author: nil, labels: nil

  @impl true
  def parse(issues), do: {:ok, Enum.map(issues, &parse_issue/1)}

  defp parse_issue(issue) do
    %__MODULE__{
      id: issue["id"],
      title: issue["title"],
      author: issue["user"]["login"],
      labels: Enum.map(issue["labels"], &parse_label/1)
    }
  end

  defp parse_label(label) do
    %{
      "name" => label["name"],
      "description" => label["description"]
    }
  end
end
