defmodule Swap.Notifications.Notification do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Swap.Webhooks.Webhook

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(status webhook_id)a
  @optional_fields ~w(response)a

  schema "notifications" do
    field :response, :map
    field :status, :string

    belongs_to :webhook, Webhook

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:webhook_id)
  end
end
