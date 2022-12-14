defmodule ElixbusWeb.ElixbusLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    socket = assign(socket, :light_bulb_status, "off")
    socket = assign(socket, :bus_count_status, 0)
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

    <h1>There are currently <%= @bus_count_status %> busses on the route.</h1>
    <button phx-click="1bus" onclick="loadData()">1 bus on the road</button>
    <button phx-click="2bus" onclick="loadData()">2 bus on the road</button>
    <button phx-click="3bus" onclick="loadData()">3 bus on the road</button>
    <button phx-click="4bus" onclick="loadData()">4 bus on the road</button>
    <button phx-click="5bus" onclick="loadData()">5 bus on the road</button>

    <!-- SHOW BUS ROUTE FEATURE -->

    <div id="showbus"></div>
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
        }
      }
      appendToHtml = function(contentToAdd) {
        document.getElementById("showbus").innerHTML += contentToAdd;
      }
      loadData()

    </script>


    </body>
    </html>

    """
  end

  def update_table(id, pos) do
    # TODO : Actually update the table (comment obtenir socket ???)
    #socket =
    #  socket
    #  |> assign(String.to_atom("bus_pos#{id}"), pos)
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

end
