defmodule Bus do

  # initialize the route of the bus and its id call bus_deployed
  # process needs id (?) and a String containing the name of the route in the json file
  def bus(id, route) do
    routelistmap = get_route(route)
    bus_deployed(id, routelistmap, 0, :stop)
  end

  # takes a string, returns a list of maps of the stops
  def get_route(route) do
    routes_Str = File.read!("priv/routes.json")
    routes_JS = Jason.decode!(routes_Str)
    routes_JS[route]["stops"]
  end

  # should be functionnal except reaction to messages
  # main function needs id (?), route (list of maps), actual pos (index of the list of maps), and state (atom either :enroute or :stop)
  def bus_deployed(id, route, pos, state) do

    {next_pos, next_state} = next(route, pos, state)
    time_period = goal_time(route, pos, state)

    # waits for orders from the dispatch, else waits time_period ms until next state
    receive do
      {Order} -> IO.puts("Placeholder to react to #{Order}")
    after
      time_period -> IO.puts("at state #{state} at position #{posToString(route,pos)} moving on")
    end

    bus_deployed(id, route, next_pos, next_state)
  end

  # given a route, a position and a state, it returns the next position and state, for route that are loops only
  def next(route, pos, state) do
    {new_pos, new_state} = if state == :stop do
      {pos, :enroute}
    else
      next_pos = if Enum.at(route,pos+1) != nil do
        pos+1
      else
        0
      end
      {next_pos, :stop}
    end
    {new_pos, new_state}
  end

  # given a route, a position and a state, it returns how long (ms) till next state
  def goal_time(route, pos, state) do
    stopmap = Enum.at(route,pos)
    {json_time, json_var_time} = if state == :stop do
      {stopmap["stop"], stopmap["stopVar"]}
    else
      {stopmap["trip"],stopmap["tripVar"]}
    end
    1000*(json_time + Enum.random(0..json_var_time))
  end

  # returns the name of the stop it is at
  def posToString(route,pos) do
    Enum.at(route,pos)["name"]
  end
end
