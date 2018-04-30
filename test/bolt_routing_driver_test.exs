defmodule Bolt.RoutingDriverTest do
  use ExUnit.Case
  doctest Bolt.RoutingDriver

  alias Bolt.RoutingDriver

  describe "registry_name/0" do
    test "returns the expected registry name" do
      assert :bolt_routing_driver_registry == RoutingDriver.registry_name
    end
  end

  describe "read_query/1" do
    test "with an expected result - returns the cypher result in an ok tuple" do
      cypher = "MATCH (n:Person {name: 'Adrian'}) RETURN n"

      assert {:ok, response} = RoutingDriver.read_query(cypher)
      assert response == [
        %{
          "n" => %Bolt.Sips.Types.Node{
            id: 0,
            labels: ["Person"],
            properties: %{"name" => "Adrian"}
          }
        }
      ]
    end

    test "with an empty result - returns the empty collection result in an ok tuple" do
      cypher = "MATCH (n:Person {name: 'Edu'}) RETURN n"

      assert {:ok, response} = RoutingDriver.read_query(cypher)
      assert response == []
    end
  end

  describe "write_query/1" do
    test "returns the affected nodes in an ok tuple" do
      cypher = "CREATE (n:Person {name: 'Adrian'})"

      assert {:ok, response} = RoutingDriver.write_query(cypher)
      assert response == %{
        stats: %{
          "labels-added" => 1,
          "nodes-created" => 1,
          "properties-set" => 1
        },
        type: "w"
      }
    end
  end
end
