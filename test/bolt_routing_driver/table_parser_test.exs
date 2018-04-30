defmodule Bolt.RoutingDriver.TableParserTest do
  use ExUnit.Case, async: true

  alias Bolt.RoutingDriver.{Address, Table, TableParser}

  describe "parse/1" do
    test "returns a Table struct with the expected addresses" do
      neo4j_servers_response = [
        %{
          "servers" => [
            %{"addresses" => ["core1.test:7687"], "role" => "WRITE"},
            %{
              "addresses" => ["core2.test:7688", "core3.test:7689"],
              "role" => "READ"
            },
            %{
              "addresses" => ["core1.test:7687", "core2.test:7688",
                "core3.test:7689"],
              "role" => "ROUTE"
            }
          ],
          "ttl" => 300
        }
      ]

      %Table{addresses: addresses, timestamp: _} = TableParser.parse(
        neo4j_servers_response
      )

      assert [
        %Address{
          url: "core1.test:7687",
          roles: [:writer, :router]
        },
        %Address{
          url: "core2.test:7688",
          roles: [:reader, :router]
        },
        %Address{
          url: "core3.test:7689",
          roles: [:reader, :router]
        }
      ] == addresses
    end
  end
end
