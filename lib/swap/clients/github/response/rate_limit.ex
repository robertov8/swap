defmodule Swap.Clients.Github.Response.RateLimit do
  @moduledoc false

  @behaviour Swap.Clients.Github.Response

  defstruct limit: nil, remaining: nil, reset: nil, used: nil

  def parse(rate_limit) do
    rate_limit = %__MODULE__{
      limit: rate_limit["rate"]["limit"],
      remaining: rate_limit["rate"]["remaining"],
      reset: rate_limit["rate"]["reset"],
      used: rate_limit["rate"]["used"]
    }

    {:ok, rate_limit}
  end
end
