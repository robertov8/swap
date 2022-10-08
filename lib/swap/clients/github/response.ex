defmodule Swap.Clients.Github.Response do
  @moduledoc false

  alias Swap.Clients.Github.Response

  @callback parse(data :: map() | list() | number()) :: {:ok | :error, list() | struct()}

  def parse({:error, status}, _action), do: Response.Error.parse(status)

  def parse({:ok, issues}, :issues), do: Response.Issue.parse(issues)
  def parse({:ok, issues}, :contributors), do: Response.Contributor.parse(issues)
end
