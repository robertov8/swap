defmodule Swap.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :ets.new(Swap, [:set, :public, :named_table])

    children =
      [
        # Start the Telemetry supervisor
        SwapWeb.Telemetry,
        # Start the PubSub system
        {Phoenix.PubSub, name: Swap.PubSub},
        # Start the Endpoint (http/https)
        SwapWeb.Endpoint
        # Start a worker by calling: Swap.Worker.start_link(arg)
        # {Swap.Worker, arg}
      ]
      |> start_oban_children()
      |> start_repo_children()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Swap.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SwapWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp start_repo_children(children) do
    if Application.get_env(:swap, :repo_enabled) do
      [Swap.Repo | children]
    else
      children
    end
  end

  defp start_oban_children(children) do
    if Application.get_env(:swap, :repo_enabled) do
      [{Oban, Application.fetch_env!(:swap, Oban)} | children]
    else
      children
    end
  end
end
