defmodule Bolt.RoutingDriver.LoadBalancer do
  alias Bolt.RoutingDriver.Connection
  alias Bolt.RoutingDriver.LoadBalancer.Strategies

  @callback select(connections_list ::  list(%Connection{})) :: %Connection{}

  def select(connections), do: Strategies.RoundRobin.select(connections)

  def select(connections, strategy) when is_atom(strategy) do
    case strategy do
      :random -> Strategies.Random.select(connections)
      :round_robin -> Strategies.RoundRobin.select(connections)
      _ -> raise ArgumentError, "Invalid strategy: #{strategy}"
    end
  end
end
