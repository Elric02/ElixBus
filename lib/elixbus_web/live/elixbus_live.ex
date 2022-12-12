defmodule ElixbusWeb.ElixbusLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    socket = assign(socket, :light_bulb_status, "off")
    socket = assign(socket, :bus_count_status, 3)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>The light is <%= @light_bulb_status %>. There are currently <%= @bus_count_status %> busses on the route.</h1>
    <button phx-click="on">On</button>
    <button phx-click="off">Off</button>
    <br>
    <button phx-click="1bus">1 bus on the road</button>
    <button phx-click="2bus">2 bus on the road</button>
    <button phx-click="3bus">3 bus on the road</button>
    <button phx-click="4bus">4 bus on the road</button>
    <button phx-click="5bus">5 bus on the road</button>
    """
  end

  def handle_event("on", _value, socket) do
    socket =
      socket
      |> assign(:light_bulb_status, "on")

    {:noreply, socket}
  end

  def handle_event("off", _value, socket) do
    socket =
      socket
      |> assign(:light_bulb_status, "off")

    {:noreply, socket}
  end

  def handle_event("1bus", _value, socket) do
    socket =
      socket
      |> assign(:bus_count_status, 1)

    send(:dispatch, {:change, 1})

    {:noreply, socket}
  end

  def handle_event("2bus", _value, socket) do
    socket =
      socket
      |> assign(:bus_count_status, 2)

    send(:dispatch, {:change, 2})

    {:noreply, socket}
  end

  def handle_event("3bus", _value, socket) do
    socket =
      socket
      |> assign(:bus_count_status, 3)

    send(:dispatch, {:change, 3})

    {:noreply, socket}
  end

  def handle_event("4bus", _value, socket) do
    socket =
      socket
      |> assign(:bus_count_status, 4)

    send(:dispatch, {:change, 4})

    {:noreply, socket}
  end

  def handle_event("5bus", _value, socket) do
    socket =
      socket
      |> assign(:bus_count_status, 5)

    send(:dispatch, {:change, 5})

    {:noreply, socket}
  end

end
