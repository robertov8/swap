defmodule Swap.Repositories.RepositoryStoryQuery do
  @moduledoc false

  import Ecto.Query

  alias Swap.Repositories.RepositoryStory

  @spec with_repository_id(query :: any(), repository_id :: Ecto.UUID.t()) :: Ecto.Query.t()
  def with_repository_id(query \\ base(), repository_id) do
    where(query, repository_id: ^repository_id)
  end

  def with_inserted_at(query \\ base(), start_date, end_date) do
    where(query, [q], fragment("? BETWEEN ? AND ?", q.inserted_at, ^start_date, ^end_date))
  end

  defp base, do: RepositoryStory
end
