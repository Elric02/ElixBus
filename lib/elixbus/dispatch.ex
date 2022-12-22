defmodule Dispatch do

  # To call for first execution
  def deploy(nb, route) do
    routelistmap = get_route(route)
    createBus(0, nb, route, routelistmap)
    totallength = calculateTotalLength(routelistmap, 0)
    IO.inspect(totallength)
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
        #IO.puts("Position received from #{id} : #{pos}")
        ElixbusWeb.ElixbusLive.update_table(id, pos)
        manageBus(nb, route, routelistmap, totallength, List.replace_at(currentPos, id, pos))
      {:change, newNb} ->
        IO.puts("Change number received. New number : #{newNb}")
        changeNumber(nb, newNb, route, routelistmap, totallength, currentPos)
    end
  end

  # Changes the amount of busses on the line.
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

  # takes a string, returns a list of maps of the stops
  def get_route(route) do
    routes_Str = File.read!("priv/static/assets/routes.json")
    routes_JS = Jason.decode!(routes_Str)
    routes_JS[route]["stops"]
  end

  # returns the total length of the route in seconds
  def calculateTotalLength(routelistmap, stop) do
    if stop == length(routelistmap) do
      0
    else
      Enum.at(routelistmap, stop)["trip"] + Enum.at(routelistmap, stop)["stop"] + calculateTotalLength(routelistmap, stop+1)
    end
  end

end
