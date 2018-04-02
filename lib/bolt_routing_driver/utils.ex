defmodule Bolt.RoutingDriver.Utils do
  def now, do: :os.system_time(:milli_seconds)
end
