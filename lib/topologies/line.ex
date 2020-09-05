defmodule Line do
  use Agent

  def start_link(no_of_nodes) do
    Agent.start_link(fn -> 1..no_of_nodes end, name: :line)
  end

  def value do
    Agent.get(:line, & &1)
  end

  def delete_node(node_id) do
    Agent.update(:line, fn list -> (Enum.filter(list, fn x -> x != node_id end)) end)
  end

  def getNeighbours(node_id) do
    Line.value() |> Enum.filter(fn x -> abs(x-node_id) == 1 end)
    |>Enum.shuffle()
  end

  def init_neighbours() do
  end
end
