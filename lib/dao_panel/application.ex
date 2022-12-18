defmodule DAOPanel.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      DAOPanelWeb.Telemetry,
      # Start the Ecto repository
      DAOPanel.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: DAOPanel.PubSub},
      # Start Finch
      {Finch, name: DAOPanel.Finch},
      # Start the Endpoint (http/https)
      DAOPanelWeb.Endpoint
      # Start a worker by calling: DAOPanel.Worker.start_link(arg)
      # {DAOPanel.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DAOPanel.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DAOPanelWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
