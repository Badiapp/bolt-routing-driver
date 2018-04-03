defmodule Bolt.RoutingDriver.Config do
  def hostname, do: get_env(:hostname)

  def bolt_sips, do: get_env(:bolt_sips)

  defp get_env(key) do
    Application.get_env(:bolt_routing_driver, key)
  end
end
