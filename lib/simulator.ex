defmodule Simulator.CLI do


  def main(args) do
    [a,b,c] = Enum.map(args, fn x -> x end)
    [no_of_nodes,topology,algorithm] = [String.to_integer(a), topology_to_atom(b), algorithm_to_atom(c)]

    {:ok, pid} = Project2.MainSupervisor.start_link([topology,no_of_nodes])


    case CurrentTopology.value[:topology] do
			:line -> Line.init_neighbours()
			:full -> FullNetwork.init_neighbours()
			:random_2d_grid -> Random2dGrid.init_neighbours()
			:torus_3d -> Torus3D.init_neighbours()
			:honeycomb -> Honeycomb.init_neighbours()
			:rand_honeycomb -> RandHoneycomb.init_neighbours()
					_ 		-> IO.puts "Incorrect topology"
		end


    [{node_pid, _value}] = Registry.lookup(Registry.ViaTest, Enum.random(1..CurrentTopology.value[:no_of_nodes]))
    Timer.start_link(self())

     case algorithm do
      :gossip -> TransmissionNode.transmit_rumour(node_pid, 0, -1)
      :push_sum -> TransmissionNode.transmit_message(node_pid, 0, 0, -1)
     end

  # :timer.sleep(20000)

      receive do
        {:task_completed, _msg}  -> ""
        _ -> IO.puts "incorrect message"
      end

  {:ok, pid}
  end

  def topology_to_atom(b) do
    case b do
      "full" -> :full
      "line" -> :line
      "rand2D" -> :random_2d_grid
      "3Dtorus" -> :torus_3d
      "honeycomb" -> :honeycomb
      "randhoneycomb" -> :rand_honeycomb
      	_ 		-> IO.puts "Incorrect topology"
    end
  end

  def algorithm_to_atom(c)  do
    case c do
      "gossip" -> :gossip
      "push-sum" -> :push_sum
    end
  end

end
