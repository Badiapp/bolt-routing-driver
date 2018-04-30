defmodule Bolt.RoutingDriver.LoadBalancer.Strategies.RoundRobinTest do
  use ExUnit.Case, async: true

  alias Bolt.RoutingDriver.Address
  alias Bolt.RoutingDriver.LoadBalancer.Strategies.RoundRobin

  describe "select/1" do
    test "returns always the connection with the lower last query timestamp" do
      address_url_1 = %Address{
        url: "url1", roles: [:reader, :router], last_query: 1523659963
      }
      address_url_2 = %Address{
        url: "url2", roles: [:reader, :router], last_query: 1523659987
      }
      address_url_3 = %Address{
        url: "url3", roles: [:reader, :router], last_query: 0
      }
      connections_with_one_zero = [address_url_1, address_url_2, address_url_3]
      
      assert RoundRobin.select(connections_with_one_zero) == address_url_3

      address_url_4 = %Address{
        url: "url4", roles: [:reader, :router], last_query: 1523659963
      }
      address_url_5 = %Address{
        url: "url5", roles: [:reader, :router], last_query: 1523659927
      }
      address_url_6 = %Address{
        url: "url6", roles: [:reader, :router], last_query: 1523660442
      }
      connections = [address_url_4, address_url_5, address_url_6]
      
      assert RoundRobin.select(connections) == address_url_5
    end
  end
end
