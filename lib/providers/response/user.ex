defmodule Providers.Response.User do
  @moduledoc false

  @derive {Jason.Encoder, only: [:login, :url, :name, :avatar_url, :company, :email]}

  defstruct login: nil, url: nil, name: nil, avatar_url: nil, company: nil, email: nil

  @type t :: %__MODULE__{
          login: String.t() | nil,
          url: String.t() | nil,
          name: String.t() | nil,
          avatar_url: String.t() | nil,
          company: String.t() | nil,
          email: String.t() | nil
        }
end
