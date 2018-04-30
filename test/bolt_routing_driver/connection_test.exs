defmodule Bolt.RoutingDriver.ConnectionTest do
  use ExUnit.Case, async: true

  alias Bolt.RoutingDriver.Connection

  describe "start_link/1" do
    test "with a new url: returns an ok tuple with the associated pid" do
      url = "core9.test:7689"
      roles = [:reader, :router]
      
      assert {:ok, _} = Connection.start_link(url: url, roles: roles)
    end

    test "with an existing url: returns an error tuple with the already started error and associated pid" do
      url = "core10.test:7688"
      roles = [:reader, :router]

      {:ok, pid} = Connection.start_link(url: url, roles: roles)
      
      assert {:error, {:already_started, pid}} = Connection.start_link(url: url, roles: roles)
    end
  end

  describe "query/2" do
    test "returns an ok tuple with the expected response" do
      url = "core1.test:7689"
      roles = [:reader, :router]
      cypher = "MATCH (n:Person) RETURN n LIMIT 1"

      Connection.start_link(url: url, roles: roles)
      
      assert {:ok, response} = Connection.query(url, cypher)
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
  end
end
