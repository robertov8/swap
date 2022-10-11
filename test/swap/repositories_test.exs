defmodule Swap.RepositoriesTest do
  @moduledoc false

  use Swap.DataCase

  alias Swap.Repositories

  describe "repositories" do
    alias Swap.Repositories.Repository

    @invalid_attrs %{name: nil, owner: nil}

    test "list_repositories/0 returns all repositories" do
      repository = insert(:repository)

      assert Repositories.list_repositories() == [repository]
    end

    test "get_repository/1 returns the repository with given id" do
      repository = insert(:repository)
      assert Repositories.get_repository(repository.id) == repository
    end

    test "create_repository/1 with valid data creates a repository" do
      valid_attrs = %{name: "some name", owner: "some owner", provider: "github"}

      assert {:ok, %Repository{} = repository} = Repositories.create_repository(valid_attrs)
      assert repository.name == "some name"
      assert repository.owner == "some owner"
      assert repository.provider == :github
    end

    test "get_or_create_repository/1 returns the repository with given name and owner" do
      valid_attrs = %{repo: "some name", owner: "some owner", repository_provider: "github"}

      assert {:ok, %Repository{} = repository} =
               Repositories.get_or_create_repository(valid_attrs)

      assert repository.name == "some name"
      assert repository.owner == "some owner"
      assert repository.provider == :github

      %{name: name, owner: owner, provider: provider} = insert(:repository)

      valid_attrs = %{repo: name, owner: owner, repository_provider: provider}

      assert {:ok, repository} = Repositories.get_or_create_repository(valid_attrs)

      assert repository.name == name
      assert repository.owner == owner

      assert {:error, :not_found} =
               Repositories.get_or_create_repository(%{repository_id: Ecto.UUID.generate()})
    end

    test "create_repository/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Repositories.create_repository(@invalid_attrs)
    end

    test "delete_repository/1 deletes the repository" do
      repository = insert(:repository)

      assert {:ok, %Repository{}} = Repositories.delete_repository(repository)
      refute Repositories.get_repository(repository.id)
    end
  end

  describe "repository_stories" do
    alias Swap.Repositories.RepositoryStory

    @invalid_attrs %{data: nil}

    test "list_repository_stories/0 returns all stories" do
      %{id: id, data: data, repository_id: repository_id} = insert(:repository_story)

      assert [
               %RepositoryStory{
                 id: ^id,
                 data: ^data,
                 repository_id: ^repository_id
               }
             ] = Repositories.list_repository_stories()
    end

    test "list_repository_stories/0 returns all stories by filter" do
      insert(:repository_story)

      today = ~N[2022-01-01 14:00:00]
      start_date = ~N[2022-01-01 00:00:00]
      end_date = ~N[2022-01-01 23:59:59]

      %{id: id, data: data, repository_id: repository_id} =
        insert(:repository_story, inserted_at: today)

      assert [
               %RepositoryStory{
                 id: ^id,
                 data: ^data,
                 repository_id: ^repository_id
               }
             ] = Repositories.list_repository_stories(id: id)

      assert [
               %RepositoryStory{
                 id: ^id,
                 data: ^data,
                 repository_id: ^repository_id
               }
             ] = Repositories.list_repository_stories(repository_id: repository_id)

      assert [
               %RepositoryStory{
                 id: ^id,
                 data: ^data,
                 repository_id: ^repository_id
               }
             ] = Repositories.list_repository_stories(inserted_at: [start_date, end_date])
    end

    test "get_repository_story/1 returns the repository_story with given id" do
      %{id: id, data: data, repository_id: repository_id} = insert(:repository_story)

      assert %RepositoryStory{
               id: ^id,
               data: ^data,
               repository_id: ^repository_id
             } = Repositories.get_repository_story(id)
    end

    test "get_repository_story_by/1 returns the repository_story with given filter" do
      insert(:repository_story)

      today = ~N[2022-01-01 14:00:00]
      start_date = ~N[2022-01-01 00:00:00]
      end_date = ~N[2022-01-01 23:59:59]

      %{id: id, data: data, repository_id: repository_id} =
        insert(:repository_story, inserted_at: today)

      refute Repositories.get_repository_story_by()
      refute Repositories.get_repository_story_by([])

      assert %RepositoryStory{
               id: ^id,
               data: ^data,
               repository_id: ^repository_id
             } = Repositories.get_repository_story_by(id: id)

      assert %RepositoryStory{
               id: ^id,
               data: ^data,
               repository_id: ^repository_id
             } = Repositories.get_repository_story_by(inserted_at: [start_date, end_date])
    end

    test "create_repository_story/1 with valid data creates a repository_story" do
      repository = insert(:repository)
      valid_attrs = %{data: %{}, repository_id: repository.id}

      assert {:ok, %RepositoryStory{} = repository_story} =
               Repositories.create_repository_story(valid_attrs)

      assert repository_story.data == %{}
    end

    test "create_repository_story/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Repositories.create_repository_story(@invalid_attrs)

      assert "can't be blank" in errors_on(changeset).data
      assert "can't be blank" in errors_on(changeset).repository_id
    end

    test "update_repository_story/2 with valid data updates the repository_story" do
      repository_story = insert(:repository_story)
      update_attrs = %{data: %{}}

      assert {:ok, %RepositoryStory{} = repository_story} =
               Repositories.update_repository_story(repository_story, update_attrs)

      assert repository_story.data == %{}
    end

    test "update_repository_story/2 with invalid data returns error changeset" do
      %{id: id, data: data, repository_id: repository_id} =
        repository_story = insert(:repository_story)

      assert {:error, %Ecto.Changeset{} = changeset} =
               Repositories.update_repository_story(repository_story, @invalid_attrs)

      assert "can't be blank" in errors_on(changeset).data

      assert %Swap.Repositories.RepositoryStory{
               id: ^id,
               data: ^data,
               repository_id: ^repository_id
             } = Repositories.get_repository_story(id)
    end

    test "delete_repository_story/1 deletes the repository_story" do
      repository_story = insert(:repository_story)

      assert {:ok, %RepositoryStory{}} = Repositories.delete_repository_story(repository_story)
      refute Repositories.get_repository_story(repository_story.id)
    end
  end
end
