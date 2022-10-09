defmodule Swap.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false

  alias Swap.Notifications.Notification
  alias Swap.Repo

  @doc """
  Returns the list of notifications.

  ## Examples

      iex> list_notifications()
      [%Notification{}, ...]

  """
  def list_notifications do
    Repo.all(Notification)
  end

  @doc """
  Gets a single notification.

  ## Examples

      iex> get_notification(123)
      %Notification{}

      iex> get_notification(456)
      nil

  """
  def get_notification(id), do: Repo.get(Notification, id)

  @doc """
  Creates a notification.

  ## Examples

      iex> create_notification(%{field: value})
      {:ok, %Notification{}}

      iex> create_notification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(attrs \\ %{}) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
  end
end
