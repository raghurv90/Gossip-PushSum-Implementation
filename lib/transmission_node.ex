defmodule TransmissionNode do

	use GenServer

	def start_link(node_id) do

			name = {:via, Registry, {Registry.ViaTest, node_id}}
			GenServer.start_link(__MODULE__, node_id,  name: name )

	end

  def init(node_id) do
		# node_properties
		{:ok, init_node_properties(node_id)}
  end

	def init_node_properties(node_id) do
		node_properties = %{:node_id => node_id, :sum => node_id,
		:weight => 1.0, :rumours_received =>0, :previous_ratios => [0,0,0,0], :rumour => 0 }
		case CurrentTopology.value[:topology] do
			:random_2d_grid ->  node_properties
															|> Map.put(:x_coordinate, :rand.uniform())
															|> Map.put(:y_coordinate, :rand.uniform())
			_ -> node_properties
		end
	end

	def get_dimensions(node_id) do
		[{pid, _value}] = Registry.lookup(Registry.ViaTest, node_id)
		GenServer.call(pid, :get_dimensions)
		# Genserver.call()
	end

	def transmit_message(pid, sum_received, weight_received, from_node_id) do
		# :timer.sleep()
       # IO.puts " inside transmit message #{from_node_id}"
		GenServer.cast(pid, {:transmit_message, sum_received, weight_received, from_node_id})
	end

	def transmit_rumour(pid, rumour, from_node_id) do
		# :timer.sleep()
		GenServer.cast(pid, {:transmit_rumour, rumour, from_node_id})
	end


	def handle_cast({:transmit_message, sum_received, weight_received, from_node_id}, map) do
		newMap = PushSum.process_and_transmit_message(map, sum_received, weight_received, from_node_id)
		{:noreply, newMap}
  end

	def handle_cast({:transmit_rumour, rumour, from_node_id}, map) do
		newMap = PlainGossip.process_and_transmit_rumour(map, rumour, from_node_id)
		{:noreply, newMap}
  end


	def get_sum_weight_ratio(node_id) do
		[{pid, _value}] = Registry.lookup(Registry.ViaTest, node_id)
		GenServer.call(pid, :sum_weight_ratio)
	end

	def get_rumour(node_id) do
		[{pid, _value}] = Registry.lookup(Registry.ViaTest, node_id)
		GenServer.call(pid, :get_rumour)
	end


	def handle_call(:sum_weight_ratio, _from, map) do
		ratio = Map.get(map, :sum)/Map.get(map,:weight)
		{:reply, ratio, map}
  end

	def handle_call(:get_rumour, _from, map) do
		ratio = Map.get(map, :rumour)
		{:reply, ratio, map}
	end

	def handle_call(:get_dimensions, _from, map) do
		dimensions = %{
			:x_coordinate => Map.get(map, :x_coordinate),
			:y_coordinate => Map.get(map, :y_coordinate),
			:z_coordinate => Map.get(map, :z_coordinate),
		}
		{:reply, dimensions, map}
	end

end
