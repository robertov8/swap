defmodule Swap.Providers.Response.Repository do
  @moduledoc false

  @derive {Jason.Encoder, only: [:user, :repository, :issues, :contributors]}

  defstruct user: nil, repository: nil, issues: nil, contributors: nil

  @type t :: %__MODULE__{
          user: String.t() | nil,
          repository: String.t() | nil,
          issues: list() | nil,
          contributors: list() | nil
        }
end
