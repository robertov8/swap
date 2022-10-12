defmodule SwapWeb.Payload.WebhookPayload do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import EctoCommons.URLValidator

  @required_fields ~w(target repository_provider)a
  @optional_fields ~w(repository_id repo owner repository_token)a

  @primary_key false
  embedded_schema do
    field :target, :string
    field :repository_id, :binary_id
    field :repo, :string
    field :owner, :string
    field :repository_provider, :string, default: "github"
    field :repository_token, :string
  end

  def create_from_params(data) do
    %__MODULE__{}
    |> cast(data, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:repository_provider, ~w(github))
    |> validate_url(:target)
    |> validate_repository(data)
    |> apply_action(:payload)
    |> parse_to_map()
  end

  defp validate_repository(changeset, %{"repository_id" => repository_id})
       when not is_nil(repository_id) do
    validate_required(changeset, :repository_id)
  end

  defp validate_repository(changeset, _data) do
    changeset
    |> validate_required(:repo)
    |> validate_required(:owner)
  end

  defp parse_to_map({:ok, struct}) do
    {:ok, Map.from_struct(struct)}
  end

  defp parse_to_map(changeset), do: changeset
end
