defmodule CollabDocs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CollabDocsWeb.Telemetry,
      CollabDocs.Repo,
      {DNSCluster, query: Application.get_env(:collab_docs, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CollabDocs.PubSub},
      # Start a worker by calling: CollabDocs.Worker.start_link(arg)
      # {CollabDocs.Worker, arg},
      # Start to serve requests, typically the last entry
      CollabDocsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CollabDocs.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CollabDocsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
