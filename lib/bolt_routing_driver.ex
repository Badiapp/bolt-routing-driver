defmodule Bolt.RoutingDriver do
  use Application
  use Retry

  alias Bolt.RoutingDriver

  @registry :bolt_routing_driver_registry

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Registry.child_spec(keys: :unique, name: registry_name()),
      RoutingDriver.Table.child_spec(RoutingDriver.Config.url()),
      RoutingDriver.Pool.child_spec([])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  def registry_name, do: @registry

  def read_query(cypher) do
    RoutingDriver.Table.reader_connections
    |> execute_query(cypher)
  end

  def write_query(cypher) do
    # The following block retries the query every 200 milliseconds and expires	
    # after 1 second, in order to not return an error to the first query that	
    # discovers the leader has changed	
    retry_strategy = 200 |> lin_backoff(1) |> expiry(1_000)	
    retry with: retry_strategy, rescue_only: [RoutingDriver.NotALeaderError] do	
      RoutingDriver.Table.writer_connections
      |> execute_query(cypher)
    end
  end

  defp execute_query(connections, cypher) do
    {:ok, url} = connections
    |> RoutingDriver.LoadBalancer.select()
    |> RoutingDriver.Pool.find_or_create_connection()

    RoutingDriver.Table.log_query(url)
    RoutingDriver.Connection.query(url, cypher)
    |> handle_query_response
  end

  defp handle_query_response(
    {:error, [code: "Neo.ClientError.Cluster.NotALeader", message: _]}
  ) do
      RoutingDriver.Table.notify_lead_error()
      raise RoutingDriver.NotALeaderError
  end

  defp handle_query_response(response), do: response
end
