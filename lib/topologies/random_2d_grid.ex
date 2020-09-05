defmodule Random2dGrid do
  use Agent

  def start_link(_no_of_nodes) do
    Agent.start_link(fn -> %{} end, name: :random_2d_grid)
  end

  # def init(no_of_nodes) do
  #   {:ok, init_map(no_of_nodes)}
  # end

  def value do
    Agent.get(:random_2d_grid, & &1)
  end

  def init_map(no_of_nodes) do
    %{:no_of_nodes =>no_of_nodes,
            :neighbours_list => %{}
      }
  end

  def delete_node(node_id) do
    neighbours_list = Random2dGrid.value()
    neighbours_list[node_id] |> Enum.each(fn x -> update_map(x, Enum.filter(neighbours_list[x], fn y -> y != node_id end) )end )
    update_map(node_id, [])
    # Agent.update(:random_2d_grid, &Map.delete(&1, node_id))
  end

  def getNeighbours(node_id) do
    Random2dGrid.value() |> Map.get(node_id)
  end

  def init_neighbours() do
    # IO.puts " inside init neighbours"
    1..CurrentTopology.value[:no_of_nodes]
            |> Enum.each( fn node_id -> update_map(node_id, calculate_nearest_neighbours(node_id)) end)
  end

  def update_map(node_id, neighbours) do
    Agent.update(:random_2d_grid, &Map.put(&1, node_id, neighbours))
  end

  def start_network(_no_of_nodes) do
    # Random2dGrid.start_link()
    # init_neighbours(no_of_nodes)
  end

  def calculate_nearest_neighbours(node_id) do
    1..CurrentTopology.value[:no_of_nodes]
          |> Enum.filter(fn x-> x != node_id && Random2dGrid.get_distance(x, node_id)<0.1 end)
  end

  def get_distance(node_1, node_2) do
    dimension_1 = TransmissionNode.get_dimensions(node_1)
    dimension_2 = TransmissionNode.get_dimensions(node_2)
    square = fn(a) -> a * a end

    :math.sqrt(square.(dimension_1[:x_coordinate] - dimension_2[:x_coordinate])  +
    square.(dimension_1[:y_coordinate] - dimension_2[:y_coordinate]))
  end

end
