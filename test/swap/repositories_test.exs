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
      valid_attrs = %{name: "some name", owner: "some owner"}

      assert {:ok, %Repository{} = repository} = Repositories.create_repository(valid_attrs)
      assert repository.name == "some name"
      assert repository.owner == "some owner"
    end

    test "get_or_create_repository/1 returns the repository with given name and owner" do
      valid_attrs = %{repo: "some name", owner: "some owner"}

      assert {:ok, %Repository{} = repository} =
               Repositories.get_or_create_repository(valid_attrs)

      assert repository.name == "some name"
      assert repository.owner == "some owner"

      %{name: name, owner: owner} = insert(:repository)

      assert {:ok, repository} =
               Repositories.get_or_create_repository(%{repo: name, owner: owner})

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
end
