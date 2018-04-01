defmodule Bolt.RoutingDriver.Supervisor do
  use Supervisor

  alias Bolt.RoutingDriver.{Connection, Table}

  # API

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
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
    System.get_env("NEO4J_HOST")
    |> Table.for()
    |> Map.get(:addresses)
  end

  defp local_url(url) do
    port = url |> String.split(":") |> Enum.at(1)

    "bolt://localhost:#{port}"
  end
end
