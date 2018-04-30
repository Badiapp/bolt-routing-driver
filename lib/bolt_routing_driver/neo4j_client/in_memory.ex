defmodule Bolt.RoutingDriver.Neo4jClient.InMemory do
  use Supervisor

  @behaviour Bolt.RoutingDriver.Neo4jClient

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, nil, name: opts[:name])
  end

  def conn(name), do: :in_memory_pool

  def query(:in_memory_pool, "CALL dbms.cluster.routing.getServers()") do
    {
      :ok,
      [
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
    }
  end

  def query(:in_memory_pool, "CREATE (n:Person {name: 'Adrian'})") do
    {
      :ok,
      %{
        stats: %{
          "labels-added" => 1,
          "nodes-created" => 1,
          "properties-set" => 1
        },
        type: "w"
      }
    }
  end

  def query(:in_memory_pool, "MATCH (n:Person {name: 'Adrian'}) RETURN n") do
    {
      :ok,
      [
        %{
          "n" => %Bolt.Sips.Types.Node{
            id: 0,
            labels: ["Person"],
            properties: %{"name" => "Adrian"}
          }
        }
      ]
    }
  end

  def query(:in_memory_pool, "MATCH (n:Person) RETURN n LIMIT 1") do
    {
      :ok,
      [
        %{
          "n" => %Bolt.Sips.Types.Node{
            id: 0,
            labels: ["Person"],
            properties: %{"name" => "Adrian"}
          }
        }
      ]
    }
  end

  def query(:in_memory_pool, _) do
    {:ok, []}
  end

  def init(_), do: Supervisor.init([], strategy: :one_for_one)
end
