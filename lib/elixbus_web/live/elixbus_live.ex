defmodule ElixbusWeb.ElixbusLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    socket = assign(socket, :light_bulb_status, "off")
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>The light is <%= @light_bulb_status %>.</h1>
    <button phx-click="on">On</button>
    <button phx-click="off">Off</button>
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

end
