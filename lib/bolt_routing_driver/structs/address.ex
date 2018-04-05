defmodule Bolt.RoutingDriver.Address do
  @enforce_keys [:url, :roles]
  defstruct [:url, :roles, last_query: 0]
end
