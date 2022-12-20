defmodule Solution do
  def part1(input) do
    parse_input(input)
    |> Enum.with_index(1)
    |> Enum.filter(fn {{left, right}, _} ->
      compare(left, right) == :lt
    end)
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.sum
  end

  def part2(input) do
    parse_input(input)
    |> Kernel.++([{[[2]], [[6]]}])
    |> Enum.flat_map(&Tuple.to_list/1)
    |> Enum.sort(fn left, right ->
      compare(left, right) == :lt
    end)
    |> Enum.with_index(1)
    |> Enum.filter(fn {packet, _} ->
      compare(packet, [[2]]) == :eq or compare(packet, [[6]]) == :eq
    end)
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.product
  end

  defp compare(left, right) when is_integer(left) and is_integer(right) do
    cond do
      left < right -> :lt
      left == right -> :eq
      left > right -> :gt
    end
  end

  defp compare(left, right) when is_list(left) and is_list(right) do
    cond do
      left == [] and right != [] -> :lt
      left == [] and right == [] -> :eq
      left != [] and right == [] -> :gt
      true -> case compare(hd(left), hd(right)) do
        :eq -> compare(tl(left), tl(right))
        res -> res
      end
    end
  end

  defp compare(left, right) when is_integer(left) and is_list(right) do
    compare(List.wrap(left), right)
  end

  defp compare(left, right) when is_list(left) and is_integer(right) do
    compare(left, List.wrap(right))
  end

  defp parse_input(input) do
    Enum.chunk_by(input, &(&1 == ""))
    |> Enum.filter(&(&1 != [""]))
    |> Enum.map(fn [left, right] ->
      {parse_list(left), parse_list(right)}
    end)
  end

  defp parse_list(str), do: Code.eval_string(str) |> elem(0)
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
