defmodule Bolt.RoutingDriver.LoadBalancer.Strategies.RoundRobin do
  @behaviour Bolt.RoutingDriver.LoadBalancer

  def select(connections) do
    connections
    |> Enum.sort(fn(x, y) -> x.last_query < y.last_query end)
    |> List.first
  end
end
