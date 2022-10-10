defmodule Swap.Repo.Migrations.AddObanJobsTable do
  use Ecto.Migration

  @prefix "jobs"

  def up do
    Oban.Migrations.up(version: 11, prefix: @prefix)
  end

  # We specify `version: 1` in `down`, ensuring that we'll roll all the way back down if
  # necessary, regardless of which version we've migrated `up` to.
  def down do
    Oban.Migrations.down(version: 1, prefix: @prefix)
  end
end
