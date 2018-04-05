defmodule Bolt.RoutingDriver.Connection do
  use GenServer

  require Logger

  alias Bolt.Sips
  alias Bolt.RoutingDriver.{Config, Utils}

  @enforce_keys [:url, :conn]
  defstruct [:url, :conn, timestamp: 0]

  # API

  def start_link(url: url, roles: roles) do
    GenServer.start_link(__MODULE__, url, name: via_tuple(url))
  end

  def details(url) do
    GenServer.call(via_tuple(url), :get_details)
  end

  def query(url, cypher) do
    GenServer.call(via_tuple(url), {:execute_query, cypher})
  end

  defp via_tuple(url) do
    {:via, Registry, {Bolt.RoutingDriver.registry_name(), url}}
  end

  # Server

  def init(url) do
    name = String.to_atom(url)
    Sips.start_link(Config.bolt_sips ++ [url: url, name: name])
    conn = Sips.conn(name)

    {:ok, %__MODULE__{conn: conn, url: url, timestamp: Utils.now()}}
  end

  def handle_call(:get_details, _from, connection) do
    {:reply, connection, connection}
  end

  def handle_call({:execute_query, cypher}, _from, connection) do
    Logger.debug("[Bolt.RoutingDriver] #{connection.url} query...")
    Logger.debug(cypher)
    response = Sips.query(connection.conn, cypher)

    {:reply, response, connection}
  end
end
