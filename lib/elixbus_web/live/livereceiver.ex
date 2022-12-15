defmodule LiveReceiver do

  def init(socket) do
    receive_live(socket)
  end

  def receive_live(socket) do
    receive do
      {id, pos} ->
        socket =
          socket
          |> assign(String.to_atom("bus_pos#{id}"), pos)
    end
  end

end
