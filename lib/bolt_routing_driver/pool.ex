defmodule Bolt.RoutingDriver.Pool do
  use Supervisor

  alias Bolt.RoutingDriver.{Config, Connection, Table}

  # API

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def connections do
    Supervisor.which_children(__MODULE__)
    |> Enum.map(
      fn {_, pid, _, _} ->
        Registry.keys(Bolt.RoutingDriver.registry_name(), pid)
        |> List.first
        |> Connection.details
      end
    )
  end

  def writer_connections, do: connections_by_role(:writer)
  def reader_connections, do: connections_by_role(:reader)
  def router_connections, do: connections_by_role(:router)
  
  defp connections_by_role(role) do
    connections()
    |> Enum.filter(
      fn (connection) ->
        connection.roles |> Enum.member?(role)
      end
    )
  end

  # Server
  
  def init(_) do
    children = initial_connections()
    Supervisor.init(children, strategy: :one_for_one)
  end

  defp initial_connections do
    addresses()
    |> Enum.map(
      fn(%{url: url, roles: roles}) ->
        Supervisor.child_spec(
          {Connection, url: local_url(url), roles: roles},
          id: url
        )
      end
    )
  end

  defp addresses do
    Config.url
    |> Table.for()
    |> Map.get(:addresses)
  end

  defp local_url(url) do
    port = url |> String.split(":") |> Enum.at(1)

    "bolt://localhost:#{port}"
  end
end
