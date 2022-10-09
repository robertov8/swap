defmodule Swap.Repositories.RepositoryStory do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Swap.Repositories.Repository

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(data repository_id)a

  schema "repositories_stories" do
    field :data, :map

    belongs_to :repository, Repository

    timestamps()
  end

  @doc false
  def changeset(repository_story, attrs) do
    repository_story
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:repository_id)
  end
end
