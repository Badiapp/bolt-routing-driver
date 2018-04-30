defmodule Bolt.RoutingDriver.PoolTest do
  use ExUnit.Case, async: true

  alias Bolt.RoutingDriver
  alias Bolt.RoutingDriver.{Address, Pool}

  setup do
    url = "core99.test.7689"
    on_exit fn ->
      [{pid, _}] = Registry.lookup(RoutingDriver.registry_name(), url)
      Supervisor.stop(pid)
    end

    {:ok, address: %Address{url: url, roles: [:reader, :router]}}
  end

  describe "find_or_create_connection/1" do
    test "returns an ok tuple when the connection already exists", %{address: address} do
      Bolt.RoutingDriver.Pool.find_or_create_connection(address)
      
      assert Pool.find_or_create_connection(address) == {:ok, address.url}
    end
    
    test "returns an ok tuple when the connection doesn't exist", %{address: address} do
      assert Pool.find_or_create_connection(address) == {:ok, address.url}
    end
  end
end
