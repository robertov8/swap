defmodule Swap.Repositories.Repository do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(name owner)a

  schema "repositories" do
    field :name, :string
    field :owner, :string

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
