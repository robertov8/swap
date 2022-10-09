defmodule Swap.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string
      add :response, :map
      add :webhook_id, references(:webhooks, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:notifications, [:webhook_id])
  end
end
