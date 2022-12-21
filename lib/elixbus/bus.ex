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

  # main function, it needs id (integer), route (list of maps), actual pos (index of the list of maps), and state (atom either :enroute or :stop)
  # to simulates the bus moving and waiting the process waits some time for a message and moves on
  # two messages can be received, either to end the process, or to wait a set time, if the bus is at a stop it will wait that time, else it will wait the remaining time
  # and set wait to the time to wait at the stop
  def bus_deployed(id, route, pos, state, wait) do
    # record time
    time_start = Time.utc_now()
    # send position to dispatch
    send(:dispatch, {:position, id, pos})
    # calculate next position and state
    {next_pos, next_state} = next(route, pos, state)
    # calculate the time to wait right now and the next wait time
    {time_period,wait} = if state == :stop && wait != 0 do
      {wait,0}
    else
      {goal_time(route, pos, state),wait}
    end

    # waits for orders from the dispatch, else waits time_period ms until next state
    receive do
      # receive remove and exit the process
      :remove ->
        IO.puts("Removed bus #{id}")
        Process.unregister(String.to_atom("#{id}"))
        Process.exit(self(), "ended bus")
      # receive wait a time, if stopped wait the time, else finish "moving" and set wait to the time received
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
    # waits for the time needed to "move" or to be stopped for orders
    after
      time_period ->
        IO.puts("Bus no #{id} was at state #{state} at position #{pos} for #{time_period/1000} seconds : #{posToString(route,pos)} moving on")
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
