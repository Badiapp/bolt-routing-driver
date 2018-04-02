defmodule Bolt.RoutingDriver.LoadBalancer.Strategies.Random do
  @behaviour Bolt.RoutingDriver.LoadBalancer

  def select(connections), do: Enum.random(connections)
end
