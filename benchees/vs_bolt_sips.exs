
# Compared with Bolt.Sips to check performance issues
#
# Operating System: macOS
# CPU Information: Intel(R) Core(TM) i7-7660U CPU @ 2.50GHz
# Number of Available Cores: 4
# Available memory: 16 GB
# Elixir 1.6.3
# Erlang 20.2.4
# Benchmark suite executing with the following configuration:
# warmup: 2 s
# time: 50 s
# parallel: 1
# inputs: none specified
# Estimated total run time: 1.73 min


# Benchmarking Bolt.RoutingDriver.read_query()...
# Benchmarking Bolt.Sips.query()...

# Name                                      ips        average  deviation         median         99th %
# Bolt.Sips.query()                      595.84        1.68 ms    ±23.12%        1.60 ms        3.26 ms
# Bolt.RoutingDriver.read_query()        584.42        1.71 ms    ±44.67%        1.59 ms        4.00 ms

# Comparison:
# Bolt.Sips.query()                      595.84
# Bolt.RoutingDriver.read_query()        584.42 - 1.02x slower

simple_cypher = """
  MATCH (p:Person {custom_id: 3})
  RETURN p
"""

{:ok, _pid} = Bolt.Sips.start_link(url: "core1.docker:7687", name: :benchee)
conn = Bolt.Sips.conn(:benchee)

# Creates some nodes before to start
# create_person = fn x -> Bolt.RoutingDriver.write_query("CREATE (a:Person {custom_id: #{x}})") end
# (1 .. 100) |> Enum.each(create_person)

inputs = %{
  "Simple cypher" => simple_cypher,
}

Benchee.run(
  %{
    "Bolt.RoutingDriver.read_query()" => fn (cypher) -> Bolt.RoutingDriver.read_query(cypher) end, 
    "Bolt.Sips.query()" => fn (cypher) -> Bolt.Sips.query(conn, cypher) end  
  }, time: 10, inputs: inputs)
