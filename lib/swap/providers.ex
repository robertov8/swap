defmodule Swap.Providers do
  @moduledoc """
  Esse modulo contem a camada que junta todas as traduções e tomadas de decisões
  """

  alias Swap.Providers.Response
  alias Swap.Webhooks.Webhook

  @callback limit_reached(token :: String.t() | nil) :: {:ok | :error, any()}

  @callback get_repo(owner :: String.t(), repo :: String.t(), token :: String.t() | nil) ::
              {:ok, Response.Repository.t()} | {:error, any()}

  @callback get_user(username :: String.t(), token :: String.t() | nil) :: Response.User.t()

  @cache_user_in_seconds 86_400

  @doc """
  Essa função retorna se o limite diario de requisições foi atingido

  ## Examples
      iex> limit_reached(%Webhook{})
      iex> {:error, 0}
      iex>
      iex> limit_reached(%Webhook{})
      iex> {:ok, 10}
      iex>
      iex> limit_reached(%Webhook{})
      iex> {:error, :timeout}
  """
  @spec limit_reached(webhook :: Webhook.t()) :: {:ok | :error, any()}
  def limit_reached(%Webhook{repository_token: token, repository: repository}) do
    module = get_provider(repository.provider)

    module.limit_reached(token)
  end

  @doc """
  Essa função retorna informações de um repositorio

  ## Examples
      iex> get_repo(%Webhook{})
      iex> %Response.Repository{}
      iex>
      iex> get_repo(%Webhook{})
      iex> nil
  """
  @spec get_repo(webhook :: Webhook.t()) :: Response.Repository.t() | nil
  def get_repo(%Webhook{repository_token: token, repository: repository}) do
    module = get_provider(repository.provider)

    case module.get_repo(repository.owner, repository.name, token) do
      {:ok, %Response.Repository{contributors: contributors} = repository} ->
        contributors = Enum.map(contributors, &parse_contributor(&1, module, token))

        Map.put(repository, :contributors, contributors)

      {:error, _reason} ->
        nil
    end
  end

  defp parse_contributor(%Response.Contributor{name: name} = contributor, module, token) do
    user =
      case Swap.Cache.get("users:#{name}") do
        nil ->
          user = module.get_user(name, token)
          Swap.Cache.set("users:#{name}", user, ttl: @cache_user_in_seconds)

          user

        user_cache ->
          user_cache
      end

    Map.put(contributor, :user, user)
  end

  defp get_provider(:github), do: Swap.Providers.Github
end
