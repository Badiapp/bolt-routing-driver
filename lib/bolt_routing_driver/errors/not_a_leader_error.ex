defmodule Bolt.RoutingDriver.NotALeaderError do	
  defexception message: "Should only attempt to take locks when leader"	
end
