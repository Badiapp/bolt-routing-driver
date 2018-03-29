defmodule Bolt.RoutingDriver do
  use Application

  @registry :bolt_routing_driver_registry

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Registry, [:unique, registry_name()]),
      supervisor(Bolt.RoutingDriver.DynamicSupervisor, [])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  def registry_name, do: @registry
end
