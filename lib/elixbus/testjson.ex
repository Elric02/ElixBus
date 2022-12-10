defmodule Elixbus.Testjson do

  def inputJson() do
    #IO.puts("TEST TEST TEST TEST")
    routes_json = File.read!("priv/routes.json")
    routes = Jason.decode!(routes_json)
    test_json = routes["FribourgLoop"]["stops"]
    newobj = initial(test_json)
    #IO.inspect(newobj)
  end

  defp initial(maplist) do
    [head|tail] = maplist
    head["name"]
  end

end
