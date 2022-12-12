defmodule Dispatch do

  # To call for first execution
  def deploy(nb, route) do
    createBus(0, nb, route)
    manageBus(nb, route)
  end

  # Creates enough bus processes
  def createBus(currentId, nbMax, route) do
    if currentId < nbMax do
      # (fonction bus à importer de bus.ex)
      IO.puts("Creating new bus (id #{currentId}) on route #{route}")
      Process.register(spawn(Bus, :bus, [currentId, route]), String.to_atom("#{currentId}"))
      createBus(currentId + 1, nbMax, route)
    end
  end

  # Removes specified bus
  def removeBus(id) do
    send(String.to_atom("#{id}"), :remove)
    Process.unregister(String.to_atom("#{id}"))
  end

  # Receives all messages here
  def manageBus(nb, route) do
    receive do
      {:position, id, pos} ->
        IO.puts("Position received from #{id} : #{pos}")
        # TODO : store positions somewhere ? and compute if a bus is late and early
        manageBus(nb, route)
      {:change, newNb} ->
        IO.puts("Change number received. New number : #{newNb}")
        changeNumber(nb, newNb, route)
    end
  end

  # Changes the amount of busses on the line.
  def changeNumber(nb, newNb, route) do
    if newNb == nb do
      manageBus(newNb, route)
    else
      if newNb > nb do
        createBus(nb, newNb, route)
		    manageBus(newNb, route)
      else
        removeBus(nb)
        changeNumber(nb-1, newNb, route)
      end
    end
  end

end
