defmodule Swap.Repo.Migrations.CreateWebhooks do
  use Ecto.Migration

  def change do
    create table(:webhooks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :target, :string
      add :repository_id, references(:repositories, on_delete: :nothing, type: :binary_id)
      add :repository_token, :string

      timestamps()
    end

    create index(:webhooks, [:repository_id])
  end
end
