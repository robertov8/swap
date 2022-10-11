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
  def list_notifications(filters \\ []) do
    filters
    |> Enum.reduce(Notification, fn filter, query ->
      binding = Keyword.new([filter])
      where(query, ^binding)
    end)
    |> Repo.all()
  end

  @doc """
  Gets a single notification.

  ## Examples

      iex> get_notification_by(123)
      %Notification{}

      iex> get_notification_by(456)
      nil

  """
  def get_notification_by, do: nil

  def get_notification_by([]), do: nil

  def get_notification_by(filters) do
    filters
    |> Enum.reduce(Notification, fn filter, query ->
      binding = Keyword.new([filter])
      where(query, ^binding)
    end)
    |> limit(1)
    |> Repo.one()
  end

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
