defmodule Bolt.RoutingDriver.DynamicSupervisor do
  use DynamicSupervisor

  alias Bolt.RoutingDriver.Connection

  # API

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def create_connection(url: url, roles: roles) do
    child_spec = Connection.child_spec(url: url, roles: roles)
    case DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:ok, pid} -> {:ok, pid}
      {:error, error} -> {:error, error}
    end
  end

  # Server

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
