defmodule Timer do

	use GenServer

	def start_link(simulator_pid) do
			name = {:via, Registry, {Registry.ViaTest, :timer}}
			GenServer.start_link(__MODULE__, simulator_pid, name: name )
	end

  def init(simulator_pid) do
		{:ok, %{:start_time => Time.utc_now(), :simulator_pid => simulator_pid}}
  end

	def print_time_taken() do
		[{pid, _value}] = Registry.lookup(Registry.ViaTest, :timer)
		GenServer.call(pid, :time_taken)
	end

	def handle_call(:time_taken, _from, map) do
		diff = Time.diff(Time.utc_now(),Map.get(map, :start_time), :millisecond)
    IO.puts("#{diff}")
    send Map.get(map, :simulator_pid), {:task_completed, "#{diff}"}
		{:reply, diff, map}
  end

end
