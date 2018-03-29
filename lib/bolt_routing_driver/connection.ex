defmodule Bolt.RoutingDriver.Connection do
  use GenServer

  @enforce_keys [:url, :roles]
  defstruct [:url, :roles, :last_cypher]

  # API

  def start_link(url: url, roles: roles) do
    GenServer.start_link(
      __MODULE__,
      %__MODULE__{url: url, roles: roles},
      name: via_tuple(url)
    )
  end

  defp via_tuple(url) do
    {:via, Registry, {Bolt.RoutingDriver.registry_name(), url}}
  end

  # Server

  def init(state) do
    {:ok, state}
  end
end
