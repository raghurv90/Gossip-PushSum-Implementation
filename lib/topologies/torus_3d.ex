defmodule Torus3D do
  use Agent

  def start_link(_no_of_nodes) do
      # IO.puts " inside start link"
    Agent.start_link(fn -> %{} end, name: :torus_3d)
  end

  def value do
    Agent.get(:torus_3d, & &1)
  end

  def delete_node(node_id) do
    neighbours_list = Torus3D.value()
    neighbours_list[node_id] |> Enum.each(fn x -> update_map(x, Enum.filter(neighbours_list[x], fn y -> y != node_id end) )end )
    update_map(node_id, [])
    # Agent.update(:random_2d_grid, &Map.delete(&1, node_id))
  end

  def getNeighbours(node_id) do
    Torus3D.value() |> Map.get(node_id)
  end

  def init_neighbours() do
    # IO.puts " inside init neighbours"
    [node_dimension_map,dimension_node_map] = create_maps()
    1..CurrentTopology.value[:no_of_nodes]
            |> Enum.each( fn node_id -> update_map(node_id, calculate_nearest_neighbours(node_id,node_dimension_map,dimension_node_map)) end)
  end

  def create_maps() do
      # IO.puts " inside create maps"
    edge_length = cube_size(CurrentTopology.value[:no_of_nodes])
    nodes_list  = Enum.map(1.. CurrentTopology.value[:no_of_nodes], fn x -> x end)
    cube_vertices_list = for x<- 1..edge_length, y<- 1..edge_length, z<- 1..edge_length, do: [x,y,z]
    node_dimension_map = Enum.zip(nodes_list, cube_vertices_list) |> Enum.into(%{})
    dimension_node_map = Enum.zip(cube_vertices_list,nodes_list) |> Enum.into(%{})
    [node_dimension_map,dimension_node_map]
  end

  def nodes_nearest(number) do
     Enum.map(1..50, fn x -> x*x*x end) |> Enum.find(fn x-> x > number end)
  end

  def cube_size(number) do
    Enum.find(1..50,fn x-> x*x*x == number end)
  end

  def update_map(node_id, neighbours) do
    Agent.update(:torus_3d, &Map.put(&1, node_id, neighbours))
  end

  def next_node(a,edge_length) do
    cond do
      a + 1 == edge_length + 1 ->  1
      true ->  a + 1
    end
  end

  def prev_node(a,edge_length) do
    cond do
      a - 1 == 0 ->  edge_length
      true -> a - 1
    end
  end

  def calculate_nearest_neighbours(node_id,node_dimension_map,dimension_node_map) do
      # IO.puts " calculate nearest neighbours"
    edge_length = cube_size(CurrentTopology.value[:no_of_nodes])
    [x,y,z] = node_dimension_map[node_id]
    neighbours_dimensions_list = [
                                  [next_node(x,edge_length),y,z],
                                  [x,next_node(y,edge_length),z],
                                  [x,y,next_node(z,edge_length)],
                                  [prev_node(x,edge_length),y,z],
                                  [x,prev_node(y,edge_length),z],
                                  [x,y,prev_node(z,edge_length)]
                                ]
    neighbours_list = Enum.map(neighbours_dimensions_list, fn x -> dimension_node_map[x] end)
    neighbours_list
  end
end
