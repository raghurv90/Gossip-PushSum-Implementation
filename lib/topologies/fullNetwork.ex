defmodule FullNetwork do
  use Agent

  def start_link(no_of_nodes) do
    Agent.start_link(fn -> 1..no_of_nodes end, name: :full)
  end

  def value do
    Agent.get(:full, & &1)
  end

  def delete_node(node_id) do
    Agent.update(:full, fn list -> (Enum.filter(list, fn x -> x != node_id end)) end)
  end

  def getNeighbours(node_id) do
    Enum.filter(FullNetwork.value(), fn x -> x != node_id end)
  end

  def init_neighbours() do
    # IO.puts "inside init neighbours"
  end
end
