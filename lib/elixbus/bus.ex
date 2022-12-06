defmodule Bus do

  # initialize the route of the bus and its id call bus_deployed
  # process needs id and a String containing the name of the route json file
  def bus(id, route) do
    route_json = get_route(route)
    # temp as json need to be tested
    # as of now can't seem to be able to read the json file!
    IO.puts(route_json)

    first_stop = initial_stop(route)
    bus_deployed(id, route, first_stop, :stop)
  end

  # take a string, should load the routes json and get only the rout part
  # issue with loading the routes.json!
  def get_route(route) do
    routes_Str = File.read!(Path.join(:code.priv_dir(:exjson), "routes.json"))
    routes_JS = JSON.decode(routes_Str)

    routes_JS
  end

  # should be functionnal except reaction to messages
  # main function needs id, route (list), actual pos, and state (:enroute, :stop)
  def bus_deployed(id, route, pos, state) do

    {next_pos, next_state} = next(route, pos, state)
    time_period = goal_time(route, pos, state)

    # waits for orders from the dispatch, else waits time_period ms until next state
    receive do
      {Order} -> IO.puts("Placeholder to react to #{Order}")
    after
      time_period ->
    end

    bus_deployed(id, route, next_pos, next_state)
  end

  # almost valid
  # given a route, a position and a state, it returns a position and a state (and a route?)
  def next(route, pos, state) do
    {new_pos, new_state} = if state == :stop do
      {pos, :enroute}
    else
      # next line should find next_pos using the json and the actual pos
      #keyfind!(route)
      {next_pos, :stop}
    end
    {new_pos, new_state}
  end

  # almost functional
  # given a route, a position and a state, it returns how long (ms) till next state
  def goal_time(route, pos, state) do
    # this  line might change depending on how to handle the json file
    route[{"name": pos, "trip": trip, "tripVar": trip_v, "stop": stop, "stopVar": stop_v}]
    {json_time, json_var_time} = if state == :stop do
      {stop, stop_v}
    else
      {trip, trip_v}
    end
    1000*(json_time + Enum.random(0..json_var_time))
  end

  # should be functionnal, might change depending how the json object is handled
  # given a route, returns the first stop
  def initial_stop(route) do
    [name | rest] = route
    {interest,_,_,_,_} = name
    interest["name"]
  end

end
