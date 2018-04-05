defmodule Bolt.RoutingDriver.Table do
  use GenServer

  require Logger

  alias Bolt.RoutingDriver.{Address, Config, TableParser, Utils}
  alias Bolt.Sips

  defstruct addresses: [], timestamp: Utils.now()

  @ttl 500

  # API

  def start_link(url) do
    GenServer.start_link(__MODULE__, url, name: __MODULE__)
  end

  def get_table, do: GenServer.call(__MODULE__, :get_table)

  def writer_connections, do: connections_by_role(:writer)

  def reader_connections, do: connections_by_role(:reader)

  def router_connections, do: connections_by_role(:router)

  defp connections_by_role(role) do
    GenServer.call(__MODULE__, {:get_connections, role})
  end

  def log_query(url) do
    GenServer.cast(__MODULE__, {:log_query, url})
  end

  # Server

  def init(url) do
    schedule_refresh_table(url)

    {:ok, check_live_table!(url)}
  end

  def handle_call(:get_table, _from, table) do
    {:reply, table, table}
  end

  def handle_call({:get_connections, role}, _from, table) do
    connections = table.addresses
    |> Enum.filter(
      fn (connection) ->
        connection.roles |> Enum.member?(role)
      end
    )

    {:reply, connections, table}
  end

  def handle_cast({:log_query, url}, table) do
    updated_addresses = table.addresses 
    |> Enum.map(
      fn(%Address{} = address) ->
        if address.url == url do
          %{address | last_query: Bolt.RoutingDriver.Utils.now}
        else
          address
        end
      end
    )
    {:noreply, %{table | addresses: updated_addresses}}
  end

  def handle_info({:refresh_table, url}, _table) do
    Logger.info("[Bolt.RoutingDriver] Refreshing table...")
    schedule_refresh_table(url)
    {:noreply, check_live_table!(url)}
  end

  defp schedule_refresh_table(url) do
    Process.send_after(self(), {:refresh_table, url}, @ttl * 1000)
  end
  
  defp get_cluster_servers(url) do
    name = :routing_servers
    {:ok, pid} = Sips.start_link(Config.bolt_sips() ++ [url: url, name: name])
    query_result = Sips.conn(name)
    |> Sips.query("CALL dbms.cluster.routing.getServers()")
 
    Supervisor.stop(pid)

    query_result
  end

  defp handle_response({:ok, response}), do: TableParser.parse(response)
  defp handle_response({:error, error}), do: raise "Error checking the routing table"

  defp check_live_table!(url) do
    url
    |> get_cluster_servers()
    |> handle_response()
  end
end
