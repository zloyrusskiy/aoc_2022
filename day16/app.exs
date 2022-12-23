defmodule Valve do
  defstruct [:label, :flow_rate, :neighbors, opened: false]
end

defmodule Solution do
  def part1(input) do
    valves = parse_valves(input)

    reach_map = calc_distances_between_working_valves(valves)

    traverse_cave(reach_map, valves)
  end

  def part2(input) do
    :not_implemented
  end

  defp traverse_cave(reach_map, valves) do
    start_valve = Enum.find(valves, &(&1.label == "AA"))

    working_valves = Enum.filter(valves, &(&1.flow_rate > 0))

    do_traverse_cave(start_valve, working_valves, 0, 0, reach_map)
  end

  defp do_traverse_cave(_, _, cur_time, final_pressure, _) when cur_time > 30, do: final_pressure

  defp do_traverse_cave(valve = %{opened: false, flow_rate: flow_rate}, rest_valves, cur_time, final_pressure, reach_map) when flow_rate > 0 do
    do_traverse_cave(%{valve | opened: true}, rest_valves, cur_time + 1, final_pressure, reach_map)
  end

  defp do_traverse_cave(cur_valve, rest_valves, cur_time, final_pressure, reach_map) do
    new_final_pressure = final_pressure + (30 - cur_time) * cur_valve.flow_rate

    case rest_valves do
      [] -> new_final_pressure
      _ -> rest_valves
      |> Enum.map(fn valve ->
        time_to_target = Map.get(reach_map, {cur_valve.label, valve.label})

        do_traverse_cave(valve, List.delete(rest_valves, valve), cur_time + time_to_target, new_final_pressure, reach_map)
      end)
      |> Enum.max()
    end
  end

  defp calc_distances_between_working_valves(valves) do
    valves
    |> Enum.filter(fn valve -> valve.label == "AA" or valve.flow_rate > 0 end)
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

      %Valve{label: label, flow_rate: flow_rate, neighbors: neighbors}
    end)
  end
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
