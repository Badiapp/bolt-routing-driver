defmodule Bolt.RoutingDriver do
  use Application

  alias Bolt.RoutingDriver

  @registry :bolt_routing_driver_registry

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Registry.child_spec(keys: :unique, name: registry_name()),
      RoutingDriver.Pool.child_spec([])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  def registry_name, do: @registry

  def read_query(cypher) do
    RoutingDriver.Pool.reader_connections
    |> execute_query(cypher)
  end

  def write_query(cypher) do
    RoutingDriver.Pool.writer_connections
    |> execute_query(cypher)
  end

  defp execute_query(connections, cypher) do
    connections
    |> RoutingDriver.LoadBalancer.select
    |> Map.get(:url)
    |> RoutingDriver.Connection.query(cypher)
  end
end
