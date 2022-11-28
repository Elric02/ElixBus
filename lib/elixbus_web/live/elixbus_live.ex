defmodule ElixbusWeb.ElixbusLive do
  use Phoenix.LiveView

  def mount(_session, socket) do
    socket = assign(socket, :count, 0)
    {:ok, socket}
  end

  def render(assigns) do

    ~H"""
    <h1>Qui est le plus beau ? </h1>
    <button phx-click="increment">Elric</button>
    <button phx-click="decrement">Loris</button>
    """

  end

  def handle_event("increment", _, socket) do
    count = socket.assigns.count +1
    socket = assign(socket, :count, count)
    {:noreply, socket}
  end

  def handle_event("decrement", _, socket) do
    count = socket.assigns.count -1
    socket = assign(socket, :count, count)
    {:noreply, socket}
  end

end
