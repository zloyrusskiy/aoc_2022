defmodule HeightMap do
  defstruct [:map, :rows, :cols]
end

defmodule Solution do
  def part1(input) do
    height_map = parse_input_to_map(input)
    [start] = find_start_coords(height_map, [?S])

    get_shortest_path(start, height_map)
    |> length()
    |> Kernel.-(1)
  end

  def part2(input) do
    height_map = parse_input_to_map(input)

    find_start_coords(height_map, [?S, ?a])
    |> Enum.map(fn start ->
      get_shortest_path(start, height_map)
    end)
    |> Enum.filter(&(&1 != :not_found))
    |> Enum.map(fn path ->
      path
      |> length()
      |> Kernel.-(1)
    end)
    |> Enum.min()
  end

  defp get_shortest_path(cur_pos, height_map) when is_tuple(cur_pos) and is_map(height_map) do
    do_get_shortest_path([[cur_pos]], height_map, MapSet.new())
  end

  defp do_get_shortest_path([cur_path | paths], height_map, visited) do
    cur_pos = hd(cur_path)

    cond do
      MapSet.member?(visited, cur_pos) ->
        do_get_shortest_path(paths, height_map, visited)

      check_if_end(cur_pos, height_map) ->
        Enum.reverse(cur_path)

      true ->
        new_paths =
          for new_pos <- get_next_valid_positions(cur_pos, height_map),
              !MapSet.member?(visited, new_pos),
              do: [new_pos | cur_path]

        do_get_shortest_path(paths ++ new_paths, height_map, MapSet.put(visited, cur_pos))
    end
  end

  defp do_get_shortest_path([], _, _), do: :not_found

  defp get_next_valid_positions({r, c}, height_map) do
    cur_int = get_char_weight({r, c}, height_map)

    [[-1, 0], [1, 0], [0, -1], [0, 1]]
    |> Enum.map(fn [dr, dc] ->
      {r + dr, c + dc}
    end)
    |> Enum.filter(fn {nr, nc} ->
      nr >= 1 and nr <= height_map.rows and nc >= 1 and nc <= height_map.cols
    end)
    |> Enum.filter(fn {nr, nc} ->
      new_int = get_char_weight({nr, nc}, height_map)

      cur_int >= new_int or cur_int == new_int - 1
    end)
  end

  defp get_char_weight(pos, height_map) do
    case Map.get(height_map.map, pos) do
      ?S -> ?a
      ?E -> ?z
      num -> num
    end
  end

  defp check_if_end(cur_pos, height_map), do: Map.get(height_map.map, cur_pos) == ?E

  defp find_start_coords(height_map, start_chars) do
    Map.filter(height_map.map, fn {_, val} -> val in start_chars end)
    |> Map.to_list()
    |> Enum.map(fn {pos, _} -> pos end)
  end

  defp parse_input_to_map(input) do
    map =
      input
      |> Enum.with_index(1)
      |> Enum.flat_map(fn {row, ri} ->
        row
        |> String.to_charlist()
        |> Enum.with_index(1)
        |> Enum.map(fn {el, ci} ->
          {{ri, ci}, el}
        end)
      end)
      |> Enum.into(Map.new())

    %HeightMap{map: map, rows: length(input), cols: String.length(hd(input))}
  end
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
