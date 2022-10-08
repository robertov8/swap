defmodule Swap.Clients.Github.Response.Contributor do
  @moduledoc false

  @behaviour Swap.Clients.Github.Response

  defstruct id: nil, login: nil, contributions: nil, user: nil

  @impl true
  def parse(contributors), do: {:ok, Enum.map(contributors, &parse_contributor/1)}

  defp parse_contributor(contributor) do
    %__MODULE__{
      id: contributor["id"],
      login: contributor["login"],
      contributions: contributor["contributions"],
      user: contributor["url"]
    }
  end
end
