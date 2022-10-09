defmodule Swap.Repo.Migrations.AddUniqueToRepositories do
  use Ecto.Migration

  def change do
    create unique_index(:repositories, [:name, :owner, :provider])
  end
end
