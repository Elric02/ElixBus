defmodule Elixbus.Testjson do

  def inputJson() do
    IO.puts("TEST TEST TEST TEST")
    File.read!("priv/routes.json")
    |> Jason.decode!()
    |> IO.inspect()
  end

end
