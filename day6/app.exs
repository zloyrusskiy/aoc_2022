defmodule Solution do
  def part1(input) do
    hd(input)
    |> find_start_marker(4)
  end

  def part2(input) do
    hd(input)
    |> find_start_marker(14)
  end

  defp find_start_marker(str, n) do
    {_, start} =
      str
      |> String.graphemes()
      |> Enum.chunk_every(n, 1, :discard)
      |> Enum.with_index()
      |> Enum.find(fn {chunk, _index} ->
        uniq = Enum.uniq(chunk)
        length(uniq) == n
      end)

    start + n
  end
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
