defmodule CaveMap do
  defstruct [:map, :rows_min, :rows_max, :cols_min, :cols_max]
end

defmodule Solution do
  def part1(input) do
    parse_input_to_cave_map(input)
    |> simulate_falling_sand_until_overflow(
      fn {r,_}, cave_map ->
        r >= cave_map.rows_max
      end,

      fn {r,_}, cave_map ->
        r >= cave_map.rows_max # fell out
      end
    )
    |> Kernel.-(1)
  end

  def part2(input) do
    parse_input_to_cave_map(input)
    |> simulate_falling_sand_until_overflow(
      fn {r,_}, cave_map ->
        r >= cave_map.rows_max + 1 # floor correction
      end,

      fn pos, _ ->
        pos == {0, 500} # blocked
      end
    )
  end

  defp simulate_falling_sand_until_overflow(cave_map, drop_stop_fn, simulation_stop_fn, iteration \\ 1) do
    sand_final_pos = drop_grain_of_sand({0, 500}, cave_map, drop_stop_fn)
    cond do
      simulation_stop_fn.(sand_final_pos, cave_map) -> iteration

      true -> simulate_falling_sand_until_overflow(
        %{cave_map | map: Map.put(cave_map.map, sand_final_pos, :sand)},
        drop_stop_fn,
        simulation_stop_fn,
        iteration + 1
        )
    end
  end

  defp drop_grain_of_sand({cr, cc}, cave_map, drop_stop_fn) do
    lb_pos = {cr + 1, cc - 1}
    b_pos = {cr + 1, cc}
    rb_pos = {cr + 1, cc + 1}

    lower_three_cells = {
      Map.get(cave_map.map, lb_pos, :empty),
      Map.get(cave_map.map, b_pos, :empty),
      Map.get(cave_map.map, rb_pos, :empty)
    }

    cond do
      drop_stop_fn.({cr, cc}, cave_map) -> {cr, cc}

      true ->
        case lower_three_cells do
          {_, :empty, _} -> drop_grain_of_sand(b_pos, cave_map, drop_stop_fn)
          {:empty, _, _} -> drop_grain_of_sand(lb_pos, cave_map, drop_stop_fn)
          {_, _, :empty} -> drop_grain_of_sand(rb_pos, cave_map, drop_stop_fn)
          _ -> {cr, cc}
        end
    end
  end

  defp parse_input_to_cave_map(input) do
    map =
      Enum.reduce(input, Map.new(), fn line, res ->
        line
        |> String.split(" -> ")
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.flat_map(fn [prev, cur] ->
          [pc, pr] = String.split(prev, ",") |> Enum.map(&String.to_integer/1)
          [cc, cr] = String.split(cur, ",") |> Enum.map(&String.to_integer/1)

          cond do
            pr != cr -> for row <- min(pr, cr)..max(pr, cr), do: {row, cc}
            pc != cc -> for col <- min(pc, cc)..max(pc, cc), do: {cr, col}
          end
        end)
        |> Enum.map(&{&1, :rock})
        |> Enum.into(%{})
        |> Map.merge(res)
      end)

    {rows_min, rows_max} =
      map
      |> Enum.map(fn {{r, _}, _} -> r end)
      |> then(&{Enum.min(&1), Enum.max(&1)})

    {cols_min, cols_max} =
      map
      |> Enum.map(fn {{_, c}, _} -> c end)
      |> then(&{Enum.min(&1), Enum.max(&1)})

    %CaveMap{
      map: map,
      rows_min: rows_min,
      cols_min: cols_min,
      rows_max: rows_max,
      cols_max: cols_max
    }
  end
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
