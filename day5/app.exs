defmodule Move do
  defstruct qty: 0, from: -1, to: -1
end

defmodule Solution do
  def part1(input) do
    parse_input(input)
    |> apply_moves(&Enum.reverse/1)
    |> get_top_crates
  end

  def part2(input) do
    parse_input(input)
    |> apply_moves(&Function.identity/1)
    |> get_top_crates
  end

  defp apply_moves({state, moves}, pre_to_move_fn), do: do_apply_moves(moves, state, pre_to_move_fn)

  defp do_apply_moves([cur_move | rest], state, pre_to_move_fn) do
    stack_crates = Map.get(state, cur_move.from, [])
    {to_move, rest_crates} = Enum.split(stack_crates, cur_move.qty)

    new_state =
      Map.update(state, cur_move.to, [], fn cur_val ->
        pre_to_move_fn.(to_move) ++ cur_val
      end)
      |> Map.put(cur_move.from, rest_crates)

    do_apply_moves(rest, new_state, pre_to_move_fn)
  end

  defp do_apply_moves([], state, _), do: state

  defp get_top_crates(state) do
    Map.keys(state)
    |> Enum.sort()
    |> Enum.map(fn key ->
      Map.get(state, key, [])
      |> List.first("")
    end)
    |> Enum.join()
  end

  defp parse_input(input) do
    {stack_lines, [_ | moves_lines]} =
      Enum.split_while(input, fn line -> String.length(line) > 0 end)

    state =
      stack_lines
      |> Enum.filter(&String.match?(&1, ~r/[[:alpha:]]/))
      |> Enum.reduce(Map.new(), fn line, acc ->
        Regex.split(~r/.{3}(?<delim>\s)/, line, on: [:delim])
        |> Enum.with_index(1)
        |> Enum.reduce(Map.new(), fn {item, index}, acc_update ->
          case item do
            "   " -> acc_update
            "[" <> <<ch::bytes-size(1)>> <> "]" -> Map.put(acc_update, index, [ch])
          end
        end)
        |> Map.merge(acc, fn _key, v1, v2 ->
          List.wrap(v2) ++ v1
        end)
      end)

    moves =
      moves_lines
      |> Enum.map(fn line ->
        [qty, from, to] =
          Regex.run(~r/move (\d+) from (\d+) to (\d+)/, line)
          |> Enum.drop(1)
          |> Enum.map(&String.to_integer/1)

        %Move{qty: qty, from: from, to: to}
      end)

    {state, moves}
  end
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
