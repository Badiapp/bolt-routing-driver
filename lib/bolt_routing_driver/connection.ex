defmodule Bolt.RoutingDriver.Connection do
  use GenServer

  alias Bolt.Sips
  alias Bolt.RoutingDriver.{Config, Utils}

  @enforce_keys [:url, :roles]
  defstruct [:url, :roles, :conn, last_query: 0]

  # API

  def start_link(url: url, roles: roles) do
    GenServer.start_link(
      __MODULE__,
      %__MODULE__{url: url, roles: roles},
      name: via_tuple(url)
    )
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

  def init(%__MODULE__{url: url} = connection) do
    name = String.to_atom(url)
    Sips.start_link(Config.bolt_sips ++ [url: url, name: name])
    conn = Sips.conn(name)

    {:ok, %__MODULE__{connection | conn: conn}}
  end

  def handle_call(:get_details, _from, connection) do
    {:reply, connection, connection}
  end

  def handle_call({:execute_query, cypher}, _from, connection) do
    response = Sips.query(connection.conn, cypher)
    {:reply, response, %{connection | last_query: Utils.now()}}
  end
end
