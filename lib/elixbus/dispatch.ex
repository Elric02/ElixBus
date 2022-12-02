defmodule dispatch do

  def deploy(nb, route) do
    createBus(0, nb, route)
    manageBus()
  end

  def createBus(currentId, nbMax, route) do
    if currentId < nbMax do
      # fonction bus à importer de bus.ex
      IO.puts("Creating new bus, id = #{currentId}")
      Process.register(spawn(__MODULE__, :bus, [route]), String.to_atom("#{currentId}"))¨
      createBus(currentId + 1, nbMax, route)
    end
  end

  def manageBus() do
    receive do
      message ->
        IO.puts("Message received")
    end
  end

end
