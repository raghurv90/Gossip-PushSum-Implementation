defmodule RandHoneycomb do
  use Agent

  def start_link(_no_of_nodes) do
    Agent.start_link(fn -> %{} end, name: :rand_honeycomb)
  end

  def value do
    Agent.get(:rand_honeycomb, & &1)
  end

  def delete_node(node_id) do
    neighbours_list = RandHoneycomb.value()
    neighbours_list[node_id] |> Enum.each(fn x -> update_map(x, Enum.filter(neighbours_list[x], fn y -> y != node_id end) )end )
    update_map(node_id, [])
    # Agent.update(:random_2d_grid, &Map.delete(&1, node_id))
  end

  def getNeighbours(node_id) do
    RandHoneycomb.value() |> Map.get(node_id)
  end

  def init_neighbours() do
    # IO.puts " inside init neighbours"
    [node_dimension_map,dimension_node_map] = create_maps()
    1..CurrentTopology.value[:no_of_nodes]
            |> Enum.each( fn node_id -> update_map(node_id, calculate_nearest_neighbours(node_id,node_dimension_map,dimension_node_map)) end)
    create_randhoneycomb_map(RandHoneycomb.value())
  end

  def create_randhoneycomb_map(neighbours_map) do
    node_pair_list = Enum.map(1..CurrentTopology.value[:no_of_nodes], fn x -> x end) |> Enum.shuffle() |> Enum.chunk_every(2)
    Enum.each(node_pair_list, fn x -> enter_map(x,neighbours_map) end)
  end

  def enter_map([a,b],neighbours_map) do
    neighbour_list1 = neighbours_map[a] ++ [b]
    update_map(a,neighbour_list1)
    neighbour_list2 = neighbours_map[b] ++ [a]
    update_map(b,neighbour_list2)
  end

  def create_maps() do
    length = honeycomb_length(CurrentTopology.value[:no_of_nodes])
    nodes_list  = Enum.map(1.. CurrentTopology.value[:no_of_nodes], fn x -> x end)
    honeycomb_vertices_list = for x<- 1..(length+1), y<- 1..length, do: [x,y]
    node_dimension_map = Enum.zip(nodes_list, honeycomb_vertices_list) |> Enum.into(%{})
    dimension_node_map = Enum.zip(honeycomb_vertices_list, nodes_list) |> Enum.into(%{})
    [node_dimension_map,dimension_node_map]
  end

  def nodes_nearest(number) do
     Enum.filter(1..250,fn x-> rem(x,2) ==0 end) |> Enum.map(fn x -> x*(x+1) end) |> Enum.find(fn x -> x> number end)
  end

  def honeycomb_length(number) do
    Enum.filter(1..250,fn x-> rem(x,2) ==0 end) |> Enum.find(fn x-> x*(x+1) == number end)
  end

  def update_map(node_id, neighbours) do
    Agent.update(:rand_honeycomb, &Map.put(&1, node_id, neighbours))
  end

  def create_neighbours(x,y,length) do
    a = get_top(x,y,length)
    b = get_bottom(x,y,length)
    [m,n] = get_side(x,y,length)
    c = get_side_valid(m,n,length)
    Enum.filter([a,b,c], fn x -> x != [] end)
  end

  def get_top(x,y,length) do
    cond do
      x  == length + 1 -> []
      true -> [x+1,y]
    end
  end

  def get_bottom(x,y,_length) do
    cond do
      x  == 1 -> []
      true -> [x-1,y]
    end
  end

  def get_side(x,y,_length) do
    cond do
      rem(x+y,2)  == 0 -> [x,y+1]
      true -> [x,y-1]
    end
  end

  def get_side_valid(m,n,length) do
    cond do
      n  == length + 1 -> []
      n  == 0 -> []
      true -> [m,n]
    end
  end

  def calculate_nearest_neighbours(node_id,node_dimension_map,dimension_node_map) do
    length = honeycomb_length(CurrentTopology.value[:no_of_nodes])
    [x,y] = node_dimension_map[node_id]
    neighbours_dimensions_list = create_neighbours(x,y,length)
    neighbours_list = Enum.map(neighbours_dimensions_list, fn x -> dimension_node_map[x] end)
    neighbours_list
  end
end
