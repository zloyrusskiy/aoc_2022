defmodule Valve do
  defstruct [:label, :flow_rate, :neighbors]
end

defmodule ValveGraph do
  defstruct [:valve_map, :reach_map]
end

defmodule Traveller do
  defstruct [:id, :rest_time, :cur_valve, :total_pressure]
end

defmodule Solution do
  @open_valve_time 1
  @part1_time 30
  @part2_time 26
  @start_valve "AA"

  def part1(input) do
    valve_map = parse_valves(input)
    reach_map = calc_distances_between_working_valves(Map.values(valve_map))

    me = %Traveller{id: 1, rest_time: @part1_time, cur_valve: @start_valve, total_pressure: 0}

    find_max_pressure([me], %ValveGraph{valve_map: valve_map, reach_map: reach_map})
  end

  def part2(input) do
    valve_map = parse_valves(input)
    reach_map = calc_distances_between_working_valves(Map.values(valve_map))

    me = %Traveller{id: 1, rest_time: @part2_time, cur_valve: @start_valve, total_pressure: 0}
    elephant = %Traveller{id: 2, rest_time: @part2_time, cur_valve: @start_valve, total_pressure: 0}

    find_max_pressure([me, elephant], %ValveGraph{valve_map: valve_map, reach_map: reach_map})
  end

  defp find_max_pressure(travellers, graph) do
    graph.valve_map
    |> Map.values()
    |> Enum.filter(&(&1.flow_rate > 0))
    |> Enum.map(&(&1.label))
    |> do_find_max_pressure(travellers, graph)
  end

  defp do_find_max_pressure([], travellers, _) do
    travellers |> Enum.map(&(&1.total_pressure)) |> Enum.sum
  end

  defp do_find_max_pressure(rest_valves, travellers, graph) do
    with cur_traveller = %Traveller{} <- get_next_traveller(travellers)
      do
        Enum.map(rest_valves, fn next_valve ->
          mod_traveller = go_to_next_valve(cur_traveller, next_valve, graph)
          trav_id = mod_traveller.id
          mod_travellers = travellers
            |> Enum.map(fn
              %{id: ^trav_id} -> mod_traveller
              traveller -> traveller
            end)
          do_find_max_pressure(rest_valves -- [next_valve], mod_travellers, graph)
        end)
        |> Enum.max
      else
        :finish -> do_find_max_pressure([], travellers, graph)
      end
  end

  defp get_next_traveller(travellers) do
    travellers
    |> Enum.filter(&(&1.rest_time > @open_valve_time))
    |> Enum.max_by(&(&1.rest_time), &>=/2, fn -> :finish end)
  end

  defp go_to_next_valve(trav, valve_label, graph) do
    valve = Map.get(graph.valve_map, valve_label)
    time_to_reach = Map.get(graph.reach_map, {trav.cur_valve, valve_label})
    time_after = trav.rest_time - time_to_reach - @open_valve_time
    final_pressure = time_after * valve.flow_rate
    cond do
      time_after > 0 -> %{trav | cur_valve: valve_label, rest_time: time_after, total_pressure: trav.total_pressure + final_pressure }
      true -> %{trav | cur_valve: valve_label, rest_time: 0}
    end
  end

  defp calc_distances_between_working_valves(valves) do
    valves
    |> Enum.filter(fn valve -> valve.label == @start_valve or valve.flow_rate > 0 end)
    |> Enum.reduce(Map.new(), fn valve, reach_map ->
      do_calc_distances_between_working_valves([valve], 0, valve, valves, MapSet.new(), reach_map)
    end)
  end

  defp do_calc_distances_between_working_valves([], _, _, _, _, reach_map), do: reach_map

  defp do_calc_distances_between_working_valves(
         cur_valves,
         time_to_reach,
         src_valve,
         valves,
         visited,
         reach_map
       ) do
    next_labels =
      Enum.flat_map(cur_valves, fn valve -> valve.neighbors end)
      |> MapSet.new()
      |> MapSet.difference(visited)

    next_valves =
      valves
      |> Enum.filter(fn valve -> valve.label in next_labels end)

    new_reach_map =
      cur_valves
      |> Enum.filter(fn valve -> valve.flow_rate > 0 and valve.label != src_valve.label end)
      |> Enum.reduce(reach_map, fn valve, reach_map ->
        reach_map
        |> Map.put({src_valve.label, valve.label}, time_to_reach)
      end)

    do_calc_distances_between_working_valves(
      next_valves,
      time_to_reach + 1,
      src_valve,
      valves,
      MapSet.union(visited, next_labels),
      new_reach_map
    )
  end

  defp parse_valves(input) do
    input
    |> Enum.map(fn line ->
      [label, rate_str, neighbors_labels] =
        Regex.run(~r/Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.+)/, line)
        |> tl

      flow_rate = String.to_integer(rate_str)

      neighbors = String.split(neighbors_labels, ", ")

      {label, %Valve{label: label, flow_rate: flow_rate, neighbors: neighbors}}
    end)
    |> Map.new()
  end
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
