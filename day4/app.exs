defmodule Solution do
  def part1(input) do
    get_elves_assigned_sections(input)
    |> Enum.count(fn {first_section, second_section} ->
      is_overlapped(first_section, second_section)
    end)
  end

  def part2(input) do
    get_elves_assigned_sections(input)
    |> Enum.count(fn {first_section, second_section} ->
      !Range.disjoint?(first_section, second_section)
    end)
  end

  defp is_overlapped(range1, range2) do
    (range1.first >= range2.first and range1.last <= range2.last) or
    (range2.first >= range1.first and range2.last <= range1.last)
  end

  defp get_elves_assigned_sections(input) do
    input
    |> Enum.map(fn line ->
      [first, second] = String.split(line, ",")

      {convert_str_to_range(first), convert_str_to_range(second)}
    end)
  end

  defp convert_str_to_range(str) do
    [r_start, r_end] = String.split(str, "-")
    String.to_integer(r_start)..String.to_integer(r_end)
  end
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
