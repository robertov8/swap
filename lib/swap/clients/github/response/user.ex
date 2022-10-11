defmodule Swap.Clients.Github.Response.User do
  @moduledoc false

  @behaviour Swap.Clients.Github.Response

  defstruct login: nil, url: nil, name: nil, avatar_url: nil, company: nil, email: nil

  def parse(user) do
    user = %__MODULE__{
      login: user["login"],
      url: user["url"],
      name: user["name"],
      avatar_url: user["avatar_url"],
      company: user["company"],
      email: user["email"]
    }

    {:ok, user}
  end
end
