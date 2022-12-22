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
      # (fonction bus à importer de bus.ex)
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
        # Which one is the following bus in the order of the list
        if id == nb - 1 do
          nextbus = 0
          # Check if the bus is early compared to the next one on the list
          timeDiff = computeTime(routelistmap, pos, Enum.at(currentPos, nextbus))
          if timeDiff < (totallength / nb)-40 do
            timeToWait = round(((totallength / nb)-40) - timeDiff)
            IO.puts("Bus no #{id} is too early. Sending command to wait #{timeToWait} seconds")
            # send(String.to_atom("#{id}"), {:wait, timeToWait})
          end
        else
          nextbus = id + 1
          # Check if the bus is early compared to the next one on the list
          timeDiff = computeTime(routelistmap, pos, Enum.at(currentPos, nextbus))
          if timeDiff < (totallength / nb)-40 do
            timeToWait = round(((totallength / nb)-40) - timeDiff)
            IO.puts("Bus no #{id} is too early. Sending command to wait #{timeToWait} seconds")
            # send(String.to_atom("#{id}"), {:wait, timeToWait})
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
