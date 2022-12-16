defmodule Bus do

  # initialize the route of the bus and its id call bus_deployed
  # process needs id (integer) and a String containing the name of the route in the json file
  def bus(id, route) do
    routelistmap = get_route(route)
    bus_deployed(id, routelistmap, 0, :stop, 0)
  end

  # takes a string, returns a list of maps of the stops
  def get_route(route) do
    routes_Str = File.read!("priv/static/assets/routes.json")
    routes_JS = Jason.decode!(routes_Str)
    routes_JS[route]["stops"]
  end

  # should be functionnal except reaction to messages
  # main function needs id (integer), route (list of maps), actual pos (index of the list of maps), and state (atom either :enroute or :stop)
  def bus_deployed(id, route, pos, state, wait) do
    send(:dispatch, {:position, id, posToString(route,pos)})
    #record time
    time_start = Time.utc_now()

    {next_pos, next_state} = next(route, pos, state)

    # calculate the time to wait right now if we're stopped and the next time to wait
    {time_period,wait} = if state == :stop && wait != 0 do
      {wait,0}
    else
      {goal_time(route, pos, state),wait}
    end

    # waits for orders from the dispatch, else waits time_period ms until next state
    receive do
      :remove ->
        IO.puts("Removed bus #{id}")
        Process.unregister(String.to_atom("#{id}"))
        Process.exit(self(), "ended bus")
      {:wait, t} ->
        IO.puts("Dispatch asked to wait for #{t} seconds when it is stopped")
        {wait_next, wait_now} = if state == :stop do
          {0,t}
        else
          # calculate time left to travel to the next stop
          to_travel = time_period - Time.diff(time_start,Time.utc_now())
          {t,to_travel}
        end
        Process.sleep(wait_now*1000)
        # calculate the time it took to change state
        t = Time.diff(time_start, Time.utc_now())
        IO.puts("Bus no #{id} was at state #{state} at position #{pos} for #{t} seconds : #{posToString(route,pos)} moving on")
        bus_deployed(id, route, next_pos, next_state, wait_next)
    after
      time_period ->
        IO.puts("Bus no #{id} was at state #{state} at position #{pos} for #{time_period/1000} seconds : #{posToString(route,pos)} moving on")
        send(:dispatch, {:position, id, pos})
    end

    bus_deployed(id, route, next_pos, next_state, wait)
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
