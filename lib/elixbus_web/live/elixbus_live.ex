defmodule ElixbusWeb.ElixbusLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    socket = assign(socket, :light_bulb_status, "off")
    socket = assign(socket, :bus_count_status, 0)
    socket = assign(socket, :bus_pos0, 0)
    socket = assign(socket, :bus_pos1, 0)
    socket = assign(socket, :bus_pos2, 0)
    socket = assign(socket, :bus_pos3, 0)
    socket = assign(socket, :bus_pos4, 0)
    if Process.whereis(:livereceiver) == nil do
      Process.register(spawn(__MODULE__, :init_receive, [socket, 5]), :livereceiver)
    end
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <html>
    <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
    body {
      padding: 25px;
      background-color: white;
      color: black;
      font-size: 25px;
    }

    .dark-mode {
      background-color: black;
      color: white;
    }

    th {
      writing-mode: vertical-lr;
      text-align: right;
      padding: 2px;
    }

    </style>
    </head>
    <body>


    <!-- DARK MODE FEATURE -->

    <p></p>
    <button onclick="toggleDark()">Toggle dark mode</button>

    <script>
      function toggleDark() {
        var element = document.body;
        element.classList.toggle("dark-mode");
      }
    </script>

    <!-- CHANGE BUS COUNT FEATURE -->

    <h1>Number of busses currently on the route : <%= @bus_count_status %> </h1>
    <button phx-click="1bus" onclick="loadData()">1 bus on the road</button>
    <button phx-click="2bus" onclick="loadData()">2 bus on the road</button>
    <button phx-click="3bus" onclick="loadData()">3 bus on the road</button>
    <button phx-click="4bus" onclick="loadData()">4 bus on the road</button>
    <button phx-click="5bus" onclick="loadData()">5 bus on the road</button>
    <button phx-click="testfunction" onclick="loadData()">Test reload</button>

    <!-- SHOW BUS ROUTE FEATURE -->

    <div id="showbus"></div>
    <h1>TEST : <%= @bus_pos0 %> <%= @bus_pos1 %> <%= @bus_pos2 %> <%= @bus_pos3 %> <%= @bus_pos4 %></h1>
    <script>
      loadData = function() {
        fetch('assets/routes.json')
          .then((response) => response.json())
          .then((json) => initTable(json));
      }
      initTable = function(json) {
        const data = Object.entries(json);
        for (var i = 0; i < data.length; i++) {
          contentToAdd = "<div class='route'><h3>" + data[i][0] + "</h3><table><tr>";
          const stops = Object.entries(data[i][1])[0][1];
          for (var j = 0; j < stops.length; j++) {
            contentToAdd += "<th>" + stops[j]["name"] + "</th>";
          }
          contentToAdd += "</tr><tr>";
          for (var j = 0; j < stops.length; j++) {
            contentToAdd += "<td></td>";
          }
          contentToAdd += "</tr></table></div>";
          setTimeout(function() { appendToHtml(contentToAdd); }, "1000");
          setTimeout(function() { testShow(); }, "1000");
        }
      }
      appendToHtml = function(contentToAdd) {
        document.getElementById("showbus").innerHTML += contentToAdd;
      }
      loadData()

      testShow = function() {
        // idée : prendre directement dans le HTML les valeurs (actuellement elles sont affichées après "TEST")
      }

    </script>


    </body>
    </html>

    """
  end

  def update_table(id, pos) do
    send(:livereceiver, {:update, id, pos})
    IO.puts("This is supposed to update the table; bus no #{id} is at pos #{pos}")
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


  def handle_event("testfunction", _value, socket) do
    send(:livereceiver, {:refresh, self()})
    receive do
      currentValues ->
        socket =
          socket
          |> assign(:bus_pos0, Enum.at(currentValues, 0))
        socket =
          socket
          |> assign(:bus_pos1, Enum.at(currentValues, 1))
        socket =
          socket
          |> assign(:bus_pos2, Enum.at(currentValues, 2))
        socket =
          socket
          |> assign(:bus_pos3, Enum.at(currentValues, 3))
        socket =
          socket
          |> assign(:bus_pos4, Enum.at(currentValues, 4))
        {:noreply, socket}
    end
  end


  def init_receive(socket, n) do
    receive_live(socket, (for n <- 0..(n-1), do: 0))
  end

  def receive_live(socket, currentValues) do
    IO.inspect(currentValues)
    receive do
      {:update, id, pos} ->
        receive_live(socket, List.replace_at(currentValues, id, pos))
      {:refresh, returnProcess} ->
        send(returnProcess, currentValues)
        receive_live(socket, currentValues)
    end
  end

end
