defmodule Bolt.RoutingDriver do
  use Application

  alias Bolt.RoutingDriver

  @registry :bolt_routing_driver_registry

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Registry.child_spec(keys: :unique, name: registry_name()),
      RoutingDriver.Table.child_spec(RoutingDriver.Config.url()),
      RoutingDriver.Pool.child_spec([])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  def registry_name, do: @registry

  def read_query(cypher) do
    RoutingDriver.Table.reader_connections
    |> execute_query(cypher)
  end

  def write_query(cypher) do
    RoutingDriver.Table.writer_connections
    |> execute_query(cypher)
  end

  defp execute_query(connections, cypher) do
    {:ok, url} = connections
    |> RoutingDriver.LoadBalancer.select()
    |> RoutingDriver.Pool.find_or_create_connection()

    RoutingDriver.Table.log_query(url)
    RoutingDriver.Connection.query(url, cypher)
  end
end
