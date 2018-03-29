defmodule Bolt.RoutingDriver.Connection do
  use GenServer

  alias Bolt.Sips

  @enforce_keys [:url, :roles]
  defstruct [:url, :roles, :conn, :last_cypher]

  # API

  def start_link(url: url, roles: roles) do
    GenServer.start_link(
      __MODULE__,
      %__MODULE__{url: url, roles: roles},
      name: via_tuple(url)
    )
  end
  
    def basic_auth do
      [
        username: System.get_env("NEO4J_USERNAME"),
        password: System.get_env("NEO4J_PWD")
      ]
    end

  defp via_tuple(url) do
    {:via, Registry, {Bolt.RoutingDriver.registry_name(), url}}
  end

  # Server

  def init(%__MODULE__{url: url} = state) do
    sips_name = String.to_atom(url)
    Sips.start_link(url: url, basic_auth: basic_auth(), name: sips_name)
    conn = Sips.conn(sips_name)

    {:ok, %__MODULE__{state | conn: conn}}
  end
end
