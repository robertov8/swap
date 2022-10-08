defmodule Swap.Repositories do
  @moduledoc """
  The Repositories context.
  """

  alias Swap.Repo
  alias Swap.Repositories.Repository

  @doc """
  Returns the list of repositories.

  ## Examples

      iex> list_repositories()
      [%Repository{}, ...]

  """
  def list_repositories do
    Repo.all(Repository)
  end

  @doc """
  Gets a single repository.

  ## Examples

      iex> get_repository!(123)
      %Repository{}

      iex> get_repository!(456)
      nil

  """
  def get_repository(id), do: Repo.get(Repository, id)

  @doc """
  Creates a repository.

  ## Examples

      iex> create_repository(%{field: value})
      {:ok, %Repository{}}

      iex> create_repository(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_repository(attrs \\ %{}) do
    %Repository{}
    |> Repository.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets or Creates a repository.

  ## Examples

      iex> get_or_create_repository(%{field: value})
      {:ok, %Repository{}}

      iex> get_or_create_repository(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def get_or_create_repository(%{repository_id: repository_id}) when not is_nil(repository_id) do
    case get_repository(repository_id) do
      nil -> {:error, :not_found}
      repository -> {:ok, repository}
    end
  end

  def get_or_create_repository(%{repo: repo, owner: owner} = attrs) do
    attrs = Map.put(attrs, :name, repo)

    case Repo.get_by(Repository, name: repo, owner: owner) do
      nil -> create_repository(attrs)
      repository -> {:ok, repository}
    end
  end

  @doc """
  Deletes a repository.

  ## Examples

      iex> delete_repository(repository)
      {:ok, %Repository{}}

      iex> delete_repository(repository)
      {:error, %Ecto.Changeset{}}

  """
  def delete_repository(%Repository{} = repository) do
    Repo.delete(repository)
  end
end
