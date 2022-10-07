defmodule Swap.Repo do
  use Ecto.Repo,
    otp_app: :swap,
    adapter: Ecto.Adapters.Postgres
end
