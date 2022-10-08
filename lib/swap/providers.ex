defmodule Swap.Providers do
  @moduledoc """
  Esse modulo contem a camada que junta todas as traduções e tomadas de decisões
  """

  alias Swap.Providers.Response

  @callback get_repo(owner :: String.t(), repo :: String.t()) ::
              {:ok, Response.Repository.t()} | {:error, any()}

  @doc """
  Essa função retorna informações de um repositorio

  ## Examples
      iex> get_repo("swap", "swap", :github)
      iex> %Response.Repository{}

      iex> get_repo("swap", "invalid", :github)
      iex> nil
  """
  @spec get_repo(owner :: String.t(), repo :: String.t(), provider :: atom()) ::
          Response.Repository.t() | nil
  def get_repo(owner, repo, provider \\ :github) do
    module = get_provider(provider)

    case module.get_repo(owner, repo) do
      {:ok, repo} -> repo
      {:error, _reason} -> nil
    end
  end

  defp get_provider(:github), do: Swap.Providers.Github
end
