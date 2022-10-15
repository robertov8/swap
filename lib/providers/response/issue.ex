defmodule Providers.Response.Issue do
  @moduledoc false

  @derive {Jason.Encoder, only: [:title, :author, :labels]}

  defstruct title: nil, author: nil, labels: nil

  @type t :: %__MODULE__{
          title: String.t() | nil,
          author: String.t() | nil,
          labels: String.t() | nil
        }
end
