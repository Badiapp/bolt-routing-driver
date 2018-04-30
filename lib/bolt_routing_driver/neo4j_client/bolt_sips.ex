defmodule Bolt.RoutingDriver.Neo4jClient.Bolt.Sips do
  @behaviour Bolt.RoutingDriver.Neo4jClient

  defdelegate start_link(opts), to: Bolt.Sips
  defdelegate conn(name), to: Bolt.Sips
  defdelegate query(conn, cypher), to: Bolt.Sips
end
