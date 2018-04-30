defmodule Bolt.RoutingDriver.Config do
  def url, do: get_env(:url)

  def bolt_sips, do: get_env(:bolt_sips)

  def neo4j_client, do: get_env(:neo4j_client) || Bolt.Sips

  defp get_env(key) do
    Application.get_env(:bolt_routing_driver, key)
  end
end
