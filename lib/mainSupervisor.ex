defmodule Project2.MainSupervisor do
	use Supervisor

	def start_link([topology,no_of_nodes]) do
		Supervisor.start_link(__MODULE__, [topology,no_of_nodes], restart: :transient)
	end

	def init([topology,no_of_nodes]) do
		{:ok, _} = Registry.start_link(keys: :unique, name: Registry.ViaTest)
		CurrentTopology.start_link(topology, no_of_nodes)
		newc =  Enum.map(1..CurrentTopology.value[:no_of_nodes], fn number ->
						Supervisor.child_spec({TransmissionNode, number}, id: number,  type: :worker) end )

		case CurrentTopology.value[:topology] do
 			:line -> Line.start_link(CurrentTopology.value[:no_of_nodes])
			:full -> FullNetwork.start_link(CurrentTopology.value[:no_of_nodes])
			:random_2d_grid -> Random2dGrid.start_link(CurrentTopology.value[:no_of_nodes])
			:torus_3d -> Torus3D.start_link(CurrentTopology.value[:no_of_nodes])
			:honeycomb -> Honeycomb.start_link(CurrentTopology.value[:no_of_nodes])
			:rand_honeycomb -> RandHoneycomb.start_link(CurrentTopology.value[:no_of_nodes])
			_ 		-> IO.puts "Incorrect topology"
		end

		Supervisor.init(newc, strategy: :one_for_one, restart: :transient)
	end

end
