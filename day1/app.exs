defmodule Solution do
  def part1(input) do
    calc_elves_total_calories(input)
    |> Enum.max
  end

  def part2(input) do
    calc_elves_total_calories(input)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end

  defp calc_elves_total_calories(input) do
    input
    |> Enum.chunk_while(
      [],
      fn el, acc ->
        if el == "" do
          {:cont, acc, []}
        else
          {num, _} = Integer.parse(el)
          {:cont, [num | acc]}
        end
      end,
      fn
        [] -> {:cont, []}
        acc -> {:cont, Enum.reverse(acc), []}
      end
    )
    |> Enum.map(&Enum.sum/1)
  end
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
