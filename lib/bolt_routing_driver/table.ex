defmodule Bolt.RoutingDriver.Table do
  alias Bolt.RoutingDriver.Connection
  alias Bolt.Sips

  defstruct addresses: [], ttl: 500

  @roles %{"WRITE" => :writer, "ROUTE" => :router, "READ" => :reader}

  def for(url) do
    case get_servers(url) do
      {ok, response} -> parse_servers_response(response)
      {:error, error} -> {:error, error}
    end
  end

  defp get_servers(url) do
    name = :routing_servers
    Sips.start_link(
      url: url, basic_auth: Connection.basic_auth(), name: name
    )
    result = Sips.conn(:routing_servers) 
    |> Sips.query("CALL dbms.cluster.routing.getServers()")

    Supervisor.stop(name)

    result
  end

  defp parse_servers_response([response]) do
    %__MODULE__{
      addresses: addresses(response),
      ttl: ttl(response)
    }
  end

  defp ttl(response), do: response |> Map.get("ttl")

  defp servers(response), do: response |> Map.get("servers")

  defp addresses(response) do
    servers(response)
    |> Enum.flat_map(
      fn(%{"addresses" => addresses, "role" => role_name}) ->
        addresses |> Enum.map(fn(x) -> %{url: x, roles: [role(role_name)]} end)
      end
    )
    |> Enum.reduce([],fn(x , acc) -> insert_address(acc, x) end)
  end

  defp insert_address([], new_address), do: [new_address]

  defp insert_address(
    [%{url: url, roles: roles} = head|tail],
    %{url: url, roles: new_roles}
  ) do
    [%{head | roles: roles ++ new_roles} | tail]
  end

  defp insert_address([head|tail], new_address) do
    [head|insert_address(tail, new_address)]
  end

  defp role(name) do
    @roles |> Map.get(name)
  end
end
