defmodule Elixbus.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      # Elixbus.Repo,
      # Start the Telemetry supervisor
      ElixbusWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Elixbus.PubSub},
      # Start the Endpoint (http/https)
      ElixbusWeb.Endpoint
      # Start a worker by calling: Elixbus.Worker.start_link(arg)
      # {Elixbus.Worker, arg}
    ]

    Elixbus.Testjson.inputJson()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Elixbus.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixbusWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
