use Mix.Config

config :bolt_routing_driver,
  url: "localhost:7687",
  neo4j_client: Bolt.RoutingDriver.Neo4jClient.InMemory,
  bolt_sips: [
    basic_auth: [username: "neo4j", password: "changeme"],
    pool_size: 5
  ]
