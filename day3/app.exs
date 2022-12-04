defmodule Solution do
  def part1(input) do
    convert_input_string_halves(input)
    |> Enum.map(fn {left, right} ->
      first_item_types = get_rucksack_items(left)
      second_item_types = get_rucksack_items(right)

      [item_type] =
        MapSet.intersection(first_item_types, second_item_types)
        |> MapSet.to_list()

      get_item_priority(item_type)
    end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> Enum.chunk_every(6)
    |> Enum.map(fn six_chunk ->
      first_group = Enum.take(six_chunk, 3)
      second_group = Enum.drop(six_chunk, 3)

      [first_item_type] =
        get_intersection_of_mapsets(first_group |> Enum.map(&get_rucksack_items/1))
        |> MapSet.to_list()

      [second_item_type] =
        get_intersection_of_mapsets(second_group |> Enum.map(&get_rucksack_items/1))
        |> MapSet.to_list()

      get_item_priority(first_item_type) + get_item_priority(second_item_type)
    end)
    |> Enum.sum()
  end

  defp get_rucksack_items(str), do: MapSet.new(String.graphemes(str))

  defp get_intersection_of_mapsets(mapsets, res \\ nil)

  defp get_intersection_of_mapsets([], res), do: res

  defp get_intersection_of_mapsets([mapset | rest], nil),
    do: get_intersection_of_mapsets(rest, mapset)

  defp get_intersection_of_mapsets([mapset | rest], res) do
    new_res = MapSet.intersection(mapset, res)
    get_intersection_of_mapsets(rest, new_res)
  end

  defp get_item_priority(<<ord_num>>) do
    cond do
      ord_num in ?a..?z -> ord_num - 96
      ord_num in ?A..?Z -> ord_num - 64 + 26
    end
  end

  defp convert_input_string_halves(input) do
    input
    |> Enum.map(fn line ->
      line_size = String.length(line)
      String.split_at(line, div(line_size, 2))
    end)
  end
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
