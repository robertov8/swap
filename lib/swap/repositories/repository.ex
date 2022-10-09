defmodule Swap.Repositories.Repository do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          name: String.t(),
          owner: String.t(),
          provider: atom()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(name owner provider)a

  schema "repositories" do
    field :name, :string
    field :owner, :string
    field :provider, Ecto.Enum, values: [:github]

    timestamps()
  end

  @doc false
  def changeset(repository, attrs) do
    repository
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:name, :owner])
  end
end
