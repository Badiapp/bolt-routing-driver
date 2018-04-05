defmodule Bolt.RoutingDriver.TableParser do
  alias Bolt.RoutingDriver.{Address, Table}

  @roles %{"WRITE" => :writer, "ROUTE" => :router, "READ" => :reader}

  def parse([response]), do: %Table{addresses: addresses(response)}

  defp servers(response), do: Map.get(response, "servers")

  defp addresses(response) do
    servers(response)
    |> Enum.flat_map(
      fn(%{"addresses" => addresses, "role" => role_name}) ->
        addresses
        |> Enum.map(fn(x) -> %Address{url: x, roles: [role(role_name)]} end)
      end
    )
    |> Enum.reduce([],fn(x , acc) -> insert_address(acc, x) end)
  end

  defp insert_address([], new_address), do: [new_address]

  defp insert_address(
    [%Address{url: url, roles: roles} = head|tail],
    %Address{url: url, roles: new_roles}
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
