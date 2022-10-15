defmodule Providers.Response.Contributor do
  @moduledoc false

  @derive {Jason.Encoder, only: [:name, :user, :qtd_commits]}

  defstruct name: nil, user: nil, qtd_commits: nil

  @type t :: %__MODULE__{
          name: String.t() | nil,
          user: String.t() | nil,
          qtd_commits: String.t() | nil
        }
end
