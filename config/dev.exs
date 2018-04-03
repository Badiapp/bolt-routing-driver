use Mix.Config

config :bolt_routing_driver,
  url: "core1:7687",
  bolt_sips: [
    basic_auth: [username: "neo4j", password: "changeme"],
    pool_size: 10
  ]
