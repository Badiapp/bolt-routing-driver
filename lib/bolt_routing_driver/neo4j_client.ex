defmodule Bolt.RoutingDriver.Neo4jClient do
  @type conn :: DBConnection.conn()

  @callback start_link(Keyword.t()) :: Supervisor.on_start()
  @callback conn(String.t()) :: conn
  @callback query(conn, String.t()) :: {:ok, map()} | {:error, map()}
end
