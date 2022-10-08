defmodule Swap.Clients.Github.Response.Error do
  @moduledoc false

  @behaviour Swap.Clients.Github.Response

  defstruct status: nil, reason: nil

  @impl true
  def parse(204), do: build(204, "Response if repository is empty")
  def parse(301), do: build(301, "Moved permanently")
  def parse(403), do: build(403, "Forbidden")
  def parse(404), do: build(404, "Resource not found")
  def parse(422), do: build(422, "Validation failed, or spammed.")
  def parse(reason) when is_binary(reason), do: build(nil, reason)
  def parse(_reason), do: build(nil, "Error.")

  defp build(status, reason), do: {:error, %__MODULE__{status: status, reason: reason}}
end
