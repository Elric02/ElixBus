defmodule Dispatch do

  # To call for first execution
  def deploy(nb, route) do
    routelistmap = get_route(route)
    createBus(0, nb, route, routelistmap)
    totallength = computeTime(routelistmap, 0, length(routelistmap))
    IO.puts("Total length of the route : #{totallength}")
    manageBus(nb, route, routelistmap, totallength, [0, 0, 0, 0, 0])
  end

  # Creates enough bus processes
  def createBus(currentId, nbMax, route, routelistmap) do
    if currentId < nbMax do
      IO.puts("Creating new bus (id #{currentId}) on route #{route}")
      Process.register(spawn(Bus, :bus, [currentId, routelistmap]), String.to_atom("#{currentId}"))
      createBus(currentId + 1, nbMax, route, routelistmap)
    end
  end

  # Removes specified bus
  def removeBus(id) do
    send(String.to_atom("#{id}"), :remove)
  end

  # Receives all messages here
  def manageBus(nb, route, routelistmap, totallength, currentPos) do
    receive do
      {:position, id, pos} ->
        ElixbusWeb.ElixbusLive.update_table(id, pos)
        # Which one is the previous bus in the order of the list
        if id == 0 do
          previousbus = nb - 1
          # Check if the bus is early compared to the previous one in the list
          timeDiff = computeTime(routelistmap, pos, Enum.at(currentPos, previousbus))
          # Special condition : don't wait if it is bus 0 and previous one is at the same stop
          if timeDiff < (totallength / nb)*0.8 do
            timeToWait = abs(ceil(((totallength / nb)*0.7) - timeDiff))
            IO.puts("Bus no #{id} is too early (threshold : #{(totallength / nb)*0.8} seconds). Sending command to wait #{timeToWait} seconds")
            if Process.whereis(String.to_atom("#{id}")) != nil do
              send(String.to_atom("#{id}"), {:wait, timeToWait})
            end
          end
        else
          previousbus = id - 1
          # Check if the bus is early compared to the previous one in the list
          timeDiff = computeTime(routelistmap, pos, Enum.at(currentPos, previousbus))
          if timeDiff < (totallength / nb)*0.8 do
            timeToWait = abs(ceil(((totallength / nb)*0.7) - timeDiff))
            IO.puts("Bus no #{id} is too early (threshold : #{(totallength / nb)*0.8} seconds). Sending command to wait #{timeToWait} seconds")
            if Process.whereis(String.to_atom("#{id}")) != nil do
              send(String.to_atom("#{id}"), {:wait, timeToWait})
            end
          end
        end
        manageBus(nb, route, routelistmap, totallength, List.replace_at(currentPos, id, pos))
      {:change, newNb} ->
        IO.puts("Change number received. New number : #{newNb}")
        changeNumber(nb, newNb, route, routelistmap, totallength, currentPos)
    end
  end

  # Changes the amount of busses on the line
  def changeNumber(nb, newNb, route, routelistmap, totallength, currentPos) do
    if newNb == nb do
      manageBus(newNb, route, routelistmap, totallength, currentPos)
    else
      if newNb > nb do
        createBus(nb, newNb, route, routelistmap)
		    manageBus(newNb, route, routelistmap, totallength, currentPos)
      else
        removeBus(nb-1)
        changeNumber(nb-1, newNb, route, routelistmap, totallength, List.replace_at(currentPos, nb-1, 0))
      end
    end
  end

  # Takes a string, returns a list of maps of the stops
  def get_route(route) do
    routes_Str = File.read!("priv/static/assets/routes.json")
    routes_JS = Jason.decode!(routes_Str)
    routes_JS[route]["stops"]
  end

  # Returns the total length of the route interval in seconds
  def computeTime(routelistmap, firstStop, lastStop) do
    # Reached the stopping condition, or else the 2 stops are the same. Also checks the case where lastStop is 0
    if firstStop == lastStop or (firstStop == length(routelistmap) and lastStop == 0) do
      0
    else
      # Reached the end of the route, loop back to the first stop
      if firstStop == length(routelistmap) do
        Enum.at(routelistmap, 0)["trip"] + Enum.at(routelistmap, 0)["stop"] + computeTime(routelistmap, 1, lastStop)
      # Nothing particular, proceed to next stop calculation
      else
        Enum.at(routelistmap, firstStop)["trip"] + Enum.at(routelistmap, firstStop)["stop"] + computeTime(routelistmap, firstStop+1, lastStop)
      end
    end
  end

end
