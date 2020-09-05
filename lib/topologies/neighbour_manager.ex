defmodule NeighbourManager do

  def getNeighbours(current_node, no_of_neighbours) do
    nodes_list = get_all_neighbours(current_node)
    # IO.puts " #{inspect(nodes_list)}"
    neighbours =  Enum.take_random(nodes_list, no_of_neighbours)
    # IO.inspect "#{neighbours}"
    Enum.shuffle(neighbours)
  end

  def get_all_neighbours(current_node) do
    case CurrentTopology.value[:topology] do
      :line ->  Line.getNeighbours(current_node)
      :full ->  FullNetwork.getNeighbours(current_node)
      :random_2d_grid ->  Random2dGrid.getNeighbours(current_node)
      :torus_3d -> Torus3D.getNeighbours(current_node)
      :honeycomb -> Honeycomb.getNeighbours(current_node)
      :rand_honeycomb -> RandHoneycomb.getNeighbours(current_node)

      _ ->  IO.puts "something wrong"
    end
  end

  def getNeighbourPIds(from_node_id, no_of_neighbours) do
    list_of_neighbours = getNeighbours(from_node_id, no_of_neighbours);
    Enum.map(list_of_neighbours, fn neighbour -> getPidFromRegistry(neighbour) end)
  end

  def getPidFromRegistry(id) do
   case Registry.lookup(Registry.ViaTest, id) do
     [] -> nil
     [{pid, _value}] -> pid
   end
  end

end
