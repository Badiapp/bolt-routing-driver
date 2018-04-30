defmodule Bolt.RoutingDriver.Connection do
  use GenServer

  require Logger

  alias Bolt.Sips
  alias Bolt.RoutingDriver.{Config, Table, Utils}

  @enforce_keys [:url, :conn]
  defstruct [:url, :conn, timestamp: 0]

  @neo4j_client Config.neo4j_client()

  # API

  def start_link(url: url, roles: roles) do
    GenServer.start_link(__MODULE__, url, name: via_tuple(url))
  end

  def query(url, cypher) do
    GenServer.call(via_tuple(url), {:execute_query, cypher})
  end

  defp via_tuple(url) do
    {:via, Registry, {Bolt.RoutingDriver.registry_name(), url}}
  end

  # Server

  def init(url) do
    Process.flag(:trap_exit, true)
    conn = start_sips_conn(url)

    {:ok, %__MODULE__{conn: conn, url: url, timestamp: Utils.now()}}
  end

  def handle_call({:execute_query, cypher}, _from, connection) do
    Logger.debug("[Bolt.RoutingDriver] #{connection.url} query...")
    Logger.debug(cypher)
    response = @neo4j_client.query(connection.conn, cypher)

    {:reply, response, connection}
  end

  def terminate(reason, connection) do
    Logger.error("[Bolt.RoutingDriver] #{connection.url} disconnected")
    Table.remove_address(connection.url)
  end

  defp start_sips_conn(url) do
    name = String.to_atom(url)
    @neo4j_client.start_link(Config.bolt_sips ++ [url: url, name: name])
    conn = @neo4j_client.conn(name)
  end
end
