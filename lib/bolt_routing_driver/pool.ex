defmodule Bolt.RoutingDriver.Pool do
  use Supervisor

  alias Bolt.RoutingDriver
  alias Bolt.RoutingDriver.{Address, Config, Connection, Table}

  # API

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def find_or_create_connection(%Address{url: url} = address) do
    if connection_process_exists?(address) do
      {:ok, url}
    else
      create_connection_process(address)
    end
  end

  defp connection_process_exists?(%Address{url: url}) do
    case Registry.lookup(RoutingDriver.registry_name(), url) do
      [] -> false
      _ -> true
    end
  end

  def create_connection_process(%Address{url: url, roles: roles}) do
    child_spec = Supervisor.child_spec(
      {Connection, url: url, roles: roles},
      id: url
    )
    case Supervisor.start_child(__MODULE__, child_spec) do
      {:ok, _pid} -> {:ok, url}
      {:error, error} -> {:error, error}
    end
  end

  # Server
  
  def init(_) do
    Supervisor.init(children_specs(), strategy: :one_for_one)
  end

  defp children_specs do
    addresses()
    |> Enum.map(
      fn (%{url: url, roles: roles}) ->
        Supervisor.child_spec(
          {Connection, url: url, roles: roles},
          id: url,
          restart: :temporary
        )
      end
    )
  end

  defp addresses, do: Table.get_table() |> Map.get(:addresses)
end
