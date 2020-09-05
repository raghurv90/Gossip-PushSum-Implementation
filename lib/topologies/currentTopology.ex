defmodule CurrentTopology do

  use Agent

  def start_link(topology, no_of_nodes) do
   # IO.puts "#{topology}"
    map = %{topology: topology, no_of_nodes: nodes_approximate(topology, no_of_nodes)}
    Agent.start_link(fn -> map end, name: __MODULE__)
  end

  def value do
    Agent.get(__MODULE__, & &1)
  end

 def nodes_approximate(topology, no_of_nodes) do
  case topology do
       :line -> no_of_nodes
       :full -> no_of_nodes
       :random_2d_grid -> no_of_nodes
       :torus_3d -> Torus3D.nodes_nearest(no_of_nodes)
       :honeycomb -> Honeycomb.nodes_nearest(no_of_nodes)
       :rand_honeycomb -> RandHoneycomb.nodes_nearest(no_of_nodes)
   end
 end

end
