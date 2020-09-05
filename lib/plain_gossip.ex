defmodule PlainGossip do

  def process_and_transmit_rumour(current_map, rumour, from_node_id) do

     new_map = get_new_map(current_map,rumour,from_node_id)
     current_rumours_received = Map.get(new_map, :rumours_received)
     neighbour_pid = NeighbourManager.getNeighbourPIds(new_map[:node_id], 2) |> Enum.at(0)

    if (neighbour_pid != nil ) do
      if(from_node_id != -1 && current_rumours_received>=20) do
         # IO.puts("delete2 #{new_map[:node_id]}")
        delete_node(new_map[:node_id])
      end
      TransmissionNode.transmit_rumour(neighbour_pid, rumour, new_map[:node_id])
      new_map
    else
       # IO.puts("delete1 #{new_map[:node_id]}")
      delete_node(new_map[:node_id])
      Timer.print_time_taken()
      new_map
    end

  end

  def delete_node(node_id) do
    case CurrentTopology.value[:topology] do
      :line -> Line.delete_node(node_id)
      :full -> FullNetwork.delete_node(node_id)
      :random_2d_grid -> Random2dGrid.delete_node(node_id)
      :torus_3d -> Torus3D.delete_node(node_id)
      :honeycomb -> Honeycomb.delete_node(node_id)
      :rand_honeycomb -> RandHoneycomb.delete_node(node_id)
    end
  end

  def get_additional_rumours_count(from_node_id) do
    if(from_node_id == -1, do: 0 , else:  1)
  end

  def get_new_map(current_map, rumour,from_node_id) do
    current_sum = Map.get(current_map, :sum)
    current_weight = Map.get(current_map, :weight)
    current_node_id = Map.get(current_map, :node_id)
    current_rumours_received = Map.get(current_map, :rumours_received) +
                              get_additional_rumours_count(from_node_id)
    current_ratios_list = Map.get(current_map, :previous_ratios)
    current_rumour = rumour
    map = %{:node_id =>current_node_id,
            :sum => current_sum,
            :weight => current_weight,
            :rumours_received => current_rumours_received ,
            :previous_ratios => current_ratios_list,
            :rumour => current_rumour
        }
    map
  end

end
