defmodule Solution do
  def part1(input) do
    rows = parse_input(input)
    |> add_indexes()
    cols = transpose(rows)

    [
      find_visible_trees(rows),
      find_visible_trees(rows |> Enum.map(&Enum.reverse/1)),
      find_visible_trees(cols),
      find_visible_trees(cols |> Enum.map(&Enum.reverse/1)),
    ]
    |> Enum.reduce(MapSet.new, fn visible_set, acc ->
      MapSet.union(acc, visible_set)
    end)
    |> Enum.count()
  end

  def part2(input) do
    rows = parse_input(input)
    |> add_indexes()
    cols = transpose(rows)

    [
      count_visible_trees_for_each(rows),
      count_visible_trees_for_each(rows |> Enum.map(&Enum.reverse/1)),
      count_visible_trees_for_each(cols),
      count_visible_trees_for_each(cols |> Enum.map(&Enum.reverse/1)),
    ]
    |> Enum.reduce(Map.new, fn count_map, acc ->
      Map.merge(count_map, acc, fn _k, v1, v2 ->
        [v1 | List.wrap(v2)]
      end)
    end)
    |> Enum.map(fn {_k, vis_tree_counts} ->
      Enum.product(vis_tree_counts)
    end)
    |> Enum.max()
  end

  defp count_visible_trees_for_each(rows) do
    rows
    |> Enum.map(&do_count_visible_trees_for_map/1)
    |> Enum.reduce(Map.new, fn count_map, acc ->
      Map.merge(count_map, acc, fn _k, v1, v2 ->
        [v1 | List.wrap(v2)]
      end)
    end)
  end

  defp do_count_visible_trees_for_map(trees, acc \\ Map.new)

  defp do_count_visible_trees_for_map([{ind, size} | rest], acc) do
    qty = count_visible_trees(size, rest)
    do_count_visible_trees_for_map(rest, Map.put(acc, ind, qty))
  end

  defp do_count_visible_trees_for_map([], acc), do: acc

  defp count_visible_trees(cur_size,trees, qty \\ 0)
  defp count_visible_trees(cur_size, [{_, size} | rest], qty) do
    if (cur_size > size) do
      count_visible_trees(cur_size, rest, qty + 1)
    else
      count_visible_trees(cur_size, [], qty + 1)
    end
  end
  defp count_visible_trees(_, [], qty), do: qty

  defp find_visible_trees(rows) do
    rows
    |> Enum.reduce(MapSet.new, fn row, acc ->
      MapSet.union(acc, find_visible_trees_in_row(row))
    end)
  end

  defp find_visible_trees_in_row(row) do
    do_find_visible_trees_in_row(row, -1, MapSet.new)
  end

  defp do_find_visible_trees_in_row([{ind, size} | rest], highest_tree, visible_set) do
    if size > highest_tree do
      do_find_visible_trees_in_row(rest, size, MapSet.put(visible_set, ind))
    else
      do_find_visible_trees_in_row(rest, highest_tree, visible_set)
    end
  end

  defp do_find_visible_trees_in_row([], _, visible_set), do: visible_set

  defp parse_input(input) do
    input
    |> Enum.map(fn line ->
      line
      |> String.codepoints()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp add_indexes(rows) do
    rows
    |> Enum.with_index(1)
    |> Enum.map(fn {row, row_ind} ->
      row
      |> Enum.with_index(1)
      |> Enum.map(fn {el, col_ind} ->
        {{row_ind, col_ind}, el}
      end)
    end)
  end

  defp transpose(rows), do: Enum.zip_with(rows, & &1)
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
