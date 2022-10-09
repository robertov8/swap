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

  def get_or_create_repository(%{repo: repo, owner: owner, repository_provider: provider} = attrs) do
    attrs =
      attrs
      |> Map.put(:name, repo)
      |> Map.put(:provider, provider)

    case Repo.get_by(Repository, name: repo, owner: owner, provider: provider) do
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

  @doc """
  Returns the list of stories.

  ## Examples

      iex> list_stories()
      [%RepositoryStory{}, ...]

  """
  def list_stories do
    Repo.all(RepositoryStory)
  end

  @doc """
  Gets a single repository_story.

  ## Examples

      iex> get_repository_story(123)
      %RepositoryStory{}

      iex> get_repository_story(456)
      nil

  """
  def get_repository_story(id), do: Repo.get(RepositoryStory, id)

  @doc """
  Creates a repository_story.

  ## Examples

      iex> create_repository_story(%{field: value})
      {:ok, %RepositoryStory{}}

      iex> create_repository_story(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_repository_story(attrs \\ %{}) do
    %RepositoryStory{}
    |> RepositoryStory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a repository_story.

  ## Examples

      iex> update_repository_story(repository_story, %{field: new_value})
      {:ok, %RepositoryStory{}}

      iex> update_repository_story(repository_story, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_repository_story(%RepositoryStory{} = repository_story, attrs) do
    repository_story
    |> RepositoryStory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a repository_story.

  ## Examples

      iex> delete_repository_story(repository_story)
      {:ok, %RepositoryStory{}}

      iex> delete_repository_story(repository_story)
      {:error, %Ecto.Changeset{}}

  """
  def delete_repository_story(%RepositoryStory{} = repository_story) do
    Repo.delete(repository_story)
  end
end
