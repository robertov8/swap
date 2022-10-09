defmodule Swap.Repo.Migrations.CreateRepositories do
  use Ecto.Migration

  def change do
    create table(:repositories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :owner, :string
      add :provider, :string

      timestamps()
    end
  end
end
