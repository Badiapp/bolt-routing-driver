# Bolt+Routing Driver
Bolt Routing Driver, the Bolt+Routing Neo4j driver that supports [clustering](https://neo4j.com/docs/operations-manual/current/clustering/) for Elixir using [bolt_sips](https://github.com/florinpatrascu/bolt_sips).

It means that you can send a read query to the driver and using one of the load balancing strategies will forward it to a chosen core.

## Quick example
```elixir
# We need to specify when we are sending a write query that will require to be sent to the leader
iex> Bolt.RoutingDriver.write_query("CREATE (n:Person { name: 'Adrian' })")
[debug] [Bolt.RoutingDriver] localhost:7687 query...
{:ok,
 %{
   stats: %{"labels-added" => 1, "nodes-created" => 1, "properties-set" => 1},
   type: "w"
 }}

# Then we can send read queries, that will be executed in a different follower each time
iex> Bolt.RoutingDriver.read_query("MATCH (n:Person {name: 'Adrian'}) RETURN n")
[debug] [Bolt.RoutingDriver] localhost:7688 query...
{:ok,
 [
   %{
     "n" => %Bolt.Sips.Types.Node{
       id: 0,
       labels: ["Person"],
       properties: %{"name" => "Adrian"}
     }
   }
 ]}

# Now, it will run in a different follower
iex> Bolt.RoutingDriver.read_query("MATCH (n:Person {name: 'Eduard'}) RETURN n")
[debug] [Bolt.RoutingDriver] localhost:7689 query...
{:ok, []}
```
