defmodule PushSum do

  def process_and_transmit_message(current_map, sum_received, weight_received, from_node_id) do

    new_map = get_new_map(current_map, sum_received, weight_received)
    # IO.puts "#{inspect(new_map)}"
    neighbour_pid = NeighbourManager.getNeighbourPIds(new_map[:node_id], 2) |> Enum.at(0)
    if (neighbour_pid != nil ) do
       # IO.puts " inside process & transmit message"
        transmit_and_get_new_map(neighbour_pid, new_map, from_node_id)
    else
      # IO.puts("#{new_map[:node_id]} end")
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



  def get_new_map(current_map, sum_received, weight_received) do
    current_sum = Map.get(current_map, :sum) + sum_received
    current_weight = Map.get(current_map, :weight) + weight_received
    current_node_id = Map.get(current_map, :node_id)
    current_rumours_received = Map.get(current_map, :rumours_received,0)+1
    current_ratios_list = Map.get(current_map, :previous_ratios)
    current_rumour = Map.get(current_map, :rumour)
    map = %{:node_id =>current_node_id,
            :sum => current_sum,
            :weight => current_weight,
            :rumours_received => current_rumours_received ,
            :previous_ratios => current_ratios_list,
            :rumour => current_rumour
        }
    map
  end


  def get_maximum_difference(list, number) do
    list |> Enum.map(fn x -> abs(x-number) end)
         |> Enum.reduce(fn x, acc -> max(x,acc) end)
  end



  def transmit_and_get_new_map(neighbour_pid, new_map, from_node_id) do
  # IO.puts " inside transmit & get new map #{from_node_id}    #{new_map[:sum]}     #{new_map[:weight]}"
    map = %{:node_id => new_map[:node_id],
          :sum => new_map[:sum]/2,
          :weight => new_map[:weight]/2,
          :rumours_received =>  Map.get(new_map, :rumours_received,0),
          :rumour => new_map[:rumour],
          :previous_ratios => List.delete_at(new_map[:previous_ratios],0) ++ [(new_map[:sum]/2)/(new_map[:weight]/2)]

        }
    if(from_node_id != -1  &&
      get_maximum_difference(List.delete_at(new_map[:previous_ratios],0),
     ((new_map[:sum])/(new_map[:weight]))) < 0.0000000001
    ) do
      # IO.puts("#{new_map[:node_id]}")
      delete_node(new_map[:node_id])
    end
    TransmissionNode.transmit_message(neighbour_pid, new_map[:sum]/2, new_map[:weight]/2, new_map[:node_id])
    map
  end

end
