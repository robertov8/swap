defmodule Swap.Providers.Response.Repository do
  @moduledoc false

  defstruct user: nil, repository: nil, issues: nil, contributors: nil

  @type t :: %__MODULE__{
          user: String.t() | nil,
          repository: String.t() | nil,
          issues: list() | nil,
          contributors: list() | nil
        }
end
