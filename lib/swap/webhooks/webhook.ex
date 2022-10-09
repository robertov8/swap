defmodule Swap.Webhooks.Webhook do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Swap.Repositories.Repository

  @type t :: %__MODULE__{
          target: String.t(),
          repository_token: String.t(),
          repository_id: Ecto.UUID.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(target repository_id)a
  @optional_fields ~w(repository_token)a

  schema "webhooks" do
    field :target, :string
    field :repository_token, :string

    belongs_to :repository, Repository

    timestamps()
  end

  @doc false
  def changeset(webhook, attrs) do
    webhook
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:repository_id)
    |> unique_constraint([:target, :repository_id])
  end
end
