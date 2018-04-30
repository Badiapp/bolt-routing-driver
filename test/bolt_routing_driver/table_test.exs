defmodule Bolt.RoutingDriver.TableTest do
  use ExUnit.Case, async: true

  alias Bolt.RoutingDriver.{Address, Config, Table}

  defmodule Bolt.RoutingDriver.TableReset do
    def exec do
      Table
      |> Process.whereis()
      |> Process.send({:refresh_table, Config.url}, [])
    end
  end

  setup do
    on_exit fn ->
      pid = Process.whereis(Table)
      Bolt.RoutingDriver.TableReset.exec()
      :sys.get_state(pid)
    end
  end

  describe "get_table/0" do
    test "returns the expected table" do
      %Table{addresses: addresses, timestamp: _} = Table.get_table()
      assert [
        %Address{
          url: "core1.test:7687",
          roles: [:writer, :router]
        },
        %Address{
          url: "core2.test:7688",
          roles: [:reader, :router]
        },
        %Address{
          url: "core3.test:7689",
          roles: [:reader, :router]
        }
      ] == addresses
    end
  end

  describe "writer_connections/0" do
    test "return the expected address" do
      assert [
        %Address{
          url: "core1.test:7687",
          roles: [:writer, :router]
        }
      ] == Table.writer_connections()
    end
  end

  describe "reader_connections/0" do
    test "return the expected addresses" do
      assert [
        %Address{
          url: "core2.test:7688",
          roles: [:reader, :router]
        },
        %Address{
          url: "core3.test:7689",
          roles: [:reader, :router]
        }
      ] == Table.reader_connections()
    end
  end

  describe "router_connections/0" do
    test "return the expected addresses" do
      assert [
        %Address{
          url: "core1.test:7687",
          roles: [:writer, :router]
        },
        %Address{
          url: "core2.test:7688",
          roles: [:reader, :router]
        },
        %Address{
          url: "core3.test:7689",
          roles: [:reader, :router]
        }
      ] == Table.router_connections()
    end
  end

  describe "log_query/1" do
    test "modify the last query timestamp for the given url" do
      pid = Process.whereis(Table)
      url_to_log = "core1.test:7687"
      %Table{addresses: previous_addresses, timestamp: _} = Table.get_table()
      previous_address_state = Enum.find(
        previous_addresses, fn (address) -> address.url == url_to_log end
      )
      Table.log_query(url_to_log)
      state_after_execution = :sys.get_state(pid)
      %Table{addresses: new_addresses, timestamp: _} = state_after_execution
      new_address_state = Enum.find(
        new_addresses, fn (address) -> address.url == url_to_log end
      )
      
      refute previous_address_state.last_query == new_address_state.last_query
    end
  end

  describe "remove_address/1" do
    test "remove the given url from the available addresses" do
      url_to_remove = "core3.test:7689"
      %Table{addresses: previous_addresses, timestamp: _} = Table.get_table()

      assert Enum.any?(previous_addresses,
        fn (address) ->
          address.url == url_to_remove
        end
      )
      
      Table.remove_address(url_to_remove)
      %Table{addresses: new_addresses, timestamp: _} = Table.get_table()

      refute Enum.any?(new_addresses,
        fn (address) ->
          address.url == url_to_remove
        end
      )
    end
  end

  describe "notify_connection_error/0" do
    test "force to refresh the table" do
      url_to_remove = "core3.test:7689"
      %Table{addresses: previous_addresses, timestamp: _} = Table.get_table()

      assert Enum.any?(previous_addresses,
        fn (address) ->
          address.url == url_to_remove
        end
      )

      Table.remove_address(url_to_remove)
      %Table{addresses: addresses_after_remove, timestamp: _} = Table.get_table()

      refute Enum.any?(addresses_after_remove,
        fn (address) ->
          address.url == url_to_remove
        end
      )
    
      Table.notify_connection_error()
      %Table{addresses: new_addresses, timestamp: _} = Table.get_table()

      assert Enum.any?(new_addresses,
        fn (address) ->
          address.url == url_to_remove
        end
      )
    end
  end
end
