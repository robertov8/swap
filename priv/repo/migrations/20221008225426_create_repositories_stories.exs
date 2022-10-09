defmodule Swap.Repo.Migrations.CreateRepositoriesStories do
  use Ecto.Migration

  def change do
    create table(:repositories_stories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :data, :map
      add :repository_id, references(:repositories, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:repositories_stories, [:repository_id])
  end
end
