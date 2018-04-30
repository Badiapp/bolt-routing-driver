defmodule Bolt.RoutingDriver.LoadBalancer.Strategies.RandomTest do
  use ExUnit.Case, async: true

  alias Bolt.RoutingDriver.Address
  alias Bolt.RoutingDriver.LoadBalancer.Strategies.Random

  describe "select/1" do
    test "returns a connection wtih a valid url" do
      address_url_1 = %Address{
        url: "url1", roles: [:reader, :router], last_query: 1523659963
      }
      address_url_2 = %Address{
        url: "url2", roles: [:reader, :router], last_query: 1523659987
      }
      address_url_3 = %Address{
        url: "url3", roles: [:reader, :router], last_query: 0
      }
      connections = [address_url_1, address_url_2, address_url_3]
      
      assert connections |> Random.select() |> Map.get(:url) |> is_binary
    end
  end
end
