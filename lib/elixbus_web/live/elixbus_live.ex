defmodule ElixbusWeb.ElixbusLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    # Initial variables assignment of the socket
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

    table {
      table-layout: fixed;
    }

    th {
      writing-mode: vertical-lr;
      text-align: center;
      padding: 2px;
      font-size: 20px;
    }

    td {
      text-align: center;
      padding: 2px;
      font-size: 16px;
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
    <button phx-click="reloaddata" id="reloadbutton" onclick="loadData()">Reload manually</button>

    <!-- SHOW BUS ROUTE FEATURE -->

    <div id="showbus">Loading...</div>
    <h1 id ="currentpos" hidden>Current positions : <%= @bus_pos0 %> <%= @bus_pos1 %> <%= @bus_pos2 %> <%= @bus_pos3 %> <%= @bus_pos4 %></h1>
    <script>
      // Load data from the JSON
      loadData = function() {
        fetch('assets/routes.json')
          .then((response) => response.json())
          .then((json) => initTable(json));
      }
      // Create the displayed table using previously loaded data and current bus positions
      initTable = function(json) {
        const data = Object.entries(json);
        for (var i = 0; i < data.length; i++) {
          // Route name
          contentToAdd = "<div class='route'><h3>" + data[i][0] + "</h3><table><tr>";
          // Header row : stop names
          const stops = Object.entries(data[i][1])[0][1];
          for (var j = 0; j < stops.length; j++) {
            contentToAdd += "<th>" + stops[j]["name"] + "</th>";
          }
          // Next rows : bus positions
          for (var j = 0; j < 5; j++) {
            contentToAdd += "</tr><tr>";
            currentPosition = document.getElementById("currentpos").innerHTML.split(' ')[j+3];
            for (var k = 0; k < stops.length; k++) {
              if (currentPosition == k) {
                contentToAdd += "<td>" + j + "</td>";
              } else {
                contentToAdd += "<td></td>";
              }
            }
          }
          contentToAdd += "</tr></table></div>";
          // Display table only after the page initialization
          setTimeout(function() { appendToHtml(contentToAdd); }, "100");
        }
      }
      // Display table by adding code to the current html
      currentpos_buffer = 0;
      appendToHtml = function(contentToAdd) {
        currentpos = document.getElementById("currentpos").innerHTML;
        if (currentpos != currentpos_buffer) {
          document.getElementById("showbus").innerHTML = contentToAdd;
          currentpos_buffer = currentpos;
        }
      }

      loadData()

      setTimeout(function() { automaticReload(); }, "1000");

      // Reload the table periodically so that users don't have to click the reload button continuously
      automaticReload = function() {
        document.getElementById("reloadbutton").click()
        setTimeout(function() { automaticReload(); }, "1000");
      }

    </script>


    </body>
    </html>

    """
  end

  # sends an update message with the new position value of one of the busses
  def update_table(id, pos) do
    send(:livereceiver, {:update, id, pos})
  end

  # sets the bus counts to 1, handles socket value and sends message to the dispatch for it to change the bus count
  def handle_event("1bus", _value, socket) do
    socket =
      socket
      |> assign(:bus_count_status, 1)

    send(:dispatch, {:change, 1})

    {:noreply, socket}
  end

  # sets the bus counts to 2, handles socket value and sends message to the dispatch for it to change the bus count
  def handle_event("2bus", _value, socket) do
    socket =
      socket
      |> assign(:bus_count_status, 2)

    send(:dispatch, {:change, 2})

    {:noreply, socket}
  end

  # sets the bus counts to 3, handles socket value and sends message to the dispatch for it to change the bus count
  def handle_event("3bus", _value, socket) do
    socket =
      socket
      |> assign(:bus_count_status, 3)

    send(:dispatch, {:change, 3})

    {:noreply, socket}
  end

  # sets the bus counts to 4, handles socket value and sends message to the dispatch for it to change the bus count
  def handle_event("4bus", _value, socket) do
    socket =
      socket
      |> assign(:bus_count_status, 4)

    send(:dispatch, {:change, 4})

    {:noreply, socket}
  end

  # sets the bus counts to 5, handles socket value and sends message to the dispatch for it to change the bus count
  def handle_event("5bus", _value, socket) do
    socket =
      socket
      |> assign(:bus_count_status, 5)

    send(:dispatch, {:change, 5})

    {:noreply, socket}
  end

  # Refreshes the current bus positions in the socket
  def handle_event("reloaddata", _value, socket) do
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

  # Launches the receive_live function
  def init_receive(socket, n) do
    receive_live(socket, (for _ <- 0..(n-1), do: 0))
  end

  # Waits for a message, either to update its current values, or to send them to another process
  def receive_live(socket, currentValues) do
    receive do
      {:update, id, pos} ->
        receive_live(socket, List.replace_at(currentValues, id, pos))
      {:refresh, returnProcess} ->
        send(returnProcess, currentValues)
        receive_live(socket, currentValues)
    end
  end

end
