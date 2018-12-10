# Bolt+Routing Driver
Bolt Routing Driver, the Bolt+Routing Neo4j driver that supports [clustering](https://neo4j.com/docs/operations-manual/current/clustering/) for Elixir using [bolt_sips](https://github.com/florinpatrascu/bolt_sips).

It means that you can send a read query to the driver and using one of the load balancing strategies will forward it to a chosen core.
