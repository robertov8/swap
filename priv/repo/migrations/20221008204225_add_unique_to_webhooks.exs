defmodule Swap.Repo.Migrations.AddUniqueToWebhooks do
  use Ecto.Migration

  def change do
    create unique_index(:webhooks, [:target, :repository_id])
  end
end
