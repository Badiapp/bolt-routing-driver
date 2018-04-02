defmodule Bolt.RoutingDriver.LoadBalancer do
  def select(connections), do: Enum.random(connections)
end
