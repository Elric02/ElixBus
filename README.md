# Elixbus

## HOW TO USE THIS "DOCKER" VERSION

  * Create the Docker Network `docker network create elixir-net` and `docker network inspect elixir-net` 
### Launch Dispatch
  * Create a Docker container which will be used as a dispatch : `docker run --rm -it --name elixir1 -p 4000:4000 -h main --net elixir-net elixir /bin/bash`
  * Copy the project folder in your Docker volume and go inside, for example with `docker cp "C:\path\to\ElixBus" bd50c52f3e66b5c9e396eca20c9a866fa9e1be66ac3d6d3066f71467fe407a74:\`, and then `cd ElixBus` in the container
  * Launch elixir with `iex --sname dispatch --cookie secret`
  * Execute the following commands : `Mix.install [:jason]`, `c("lib/elixbus/dispatch.ex")`, `Dispatch.init(0, "FribourgLoop")`
### Launch Busses
  * Create as many Docker containers as you want to have busses. Don't forget to replace "elixir2" by the appropriate number : The first bus has the name and host "elixir2", the following ones will have elixir3, elixir4 etc : `docker run --rm -it --name elixir2 -h elixir2 --net elixir-net elixir /bin/bash`
  * Copy the project folder in your Docker volume and go inside, for example with `docker cp "C:\path\to\ElixBus" 74ab2cda779b1295bc8812a5873c867ad3442b45615891b20db44f61755218f2:\`, and then `cd ElixBus` in the container
  * Launch elixir with `iex --sname bus0 --cookie secret`. Don't forget to change bus0 by the bus number. The first bus has the name bus0, the second one bus1, then bus2 etc.
  * Execute the following commands : `c("lib/elixbus/dispatch.ex")`, `Bus.docker_bus(0)`. Don't forget to change the number 0 by your bus number. The first bus number is 0, then 1, then 2 etc (same as previous point)
### Send commands to dispatch
  * The only command you'll be needing is `send(:dispatch, {:change, 1})`. 1 can be replaced by the amount of bus you want to have. Don't set more busses than the amount of bus containers you have initiated.