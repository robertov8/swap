defmodule Swap.Repositories do
  @moduledoc """
  The Repositories context.
  """

  import Ecto.Query

  alias Swap.Repo
  alias Swap.Repositories.{Repository, RepositoryStory, RepositoryStoryQuery}

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
  Returns the list of repository_story.

  ## Examples

      iex> list_repository_stories()
      [%RepositoryStory{}, ...]

      iex> list_repository_stories(repository_id: "b8247ddb-6717-4e72-92d1-4f0295734836")
      [%RepositoryStory{}, ...]
  """
  def list_repository_stories(filters \\ []) do
    filters
    |> Enum.reduce(RepositoryStory, fn filter, query ->
      case filter do
        {:repository_id, repository_id} ->
          RepositoryStoryQuery.with_repository_id(query, repository_id)

        {:inserted_at, [start_date, end_date]} ->
          RepositoryStoryQuery.with_inserted_at(query, start_date, end_date)

        _ ->
          binding = Keyword.new([filter])
          where(query, ^binding)
      end
    end)
    |> Repo.all()
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
  Gets a single repository_story.

  ## Examples

      iex> get_repository_story_by(inserted_at: [~N[2022-01-01 00:00:00], ~N[2022-01-01 23:59:59]])
      %RepositoryStory{}

      iex> get_repository_story_by(id: "0560dcee-2b3c-410c-90c3-e2b45255f4b3")
      nil

      iex> get_repository_story_by()
      nil

      iex> get_repository_story_by([])
      nil
  """
  def get_repository_story_by, do: nil

  def get_repository_story_by([]), do: nil

  def get_repository_story_by(filters) do
    filters
    |> Enum.reduce(RepositoryStory, fn filter, query ->
      case filter do
        {:inserted_at, [start_date, end_date]} ->
          RepositoryStoryQuery.with_inserted_at(query, start_date, end_date)

        _ ->
          binding = Keyword.new([filter])
          where(query, ^binding)
      end
    end)
    |> order_by(desc: :inserted_at)
    |> limit(1)
    |> Repo.one()
  end

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
