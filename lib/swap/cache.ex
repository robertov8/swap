defmodule Swap.Cache do
  @moduledoc false

  @table_name Swap
  @now :os.system_time(:seconds)
  @cache_default_in_seconds 3600

  @spec get(key :: String.t()) :: any()
  def get(key) do
    case :ets.lookup(@table_name, key) do
      [{_key, value, expiration}] when expiration > @now ->
        value

      _ ->
        nil
    end
  end

  @spec set(key :: String.t(), value :: any(), opts :: Keyword.t()) :: any()
  def set(key, value, opts \\ []) do
    ttl = Keyword.get(opts, :ttl, @cache_default_in_seconds)

    response = {key, value, @now + ttl}

    :ets.insert(@table_name, response)

    response
  end
end
