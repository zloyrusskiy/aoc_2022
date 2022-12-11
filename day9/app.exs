defmodule Solution do
  def part1(input) do
    parse_input(input)
    |> simulate_moves()
    |> Enum.count()
  end

  def part2(input) do
    parse_input(input)
    |> simulate_moves_long(10)
    |> Enum.count()
  end

  defp simulate_moves(
         moves,
         head_coords \\ {1, 1},
         tail_coords \\ {1, 1},
         visited \\ MapSet.new()
       )

  defp simulate_moves([{_, 0} | rest], head_coords, tail_coords, visited) do
    simulate_moves(rest, head_coords, tail_coords, visited)
  end

  defp simulate_moves([{dir, qty} | rest], head_coords, tail_coords, visited) do
    new_head = move_head_by_dir(dir, head_coords)
    new_tail = calc_tail_coords(new_head, tail_coords)

    simulate_moves([{dir, qty - 1} | rest], new_head, new_tail, MapSet.put(visited, new_tail))
  end

  defp simulate_moves([], _, _, visited), do: visited

  defp simulate_moves_long(moves, snake_len) do
    head_coords = {1, 1}
    visited = MapSet.new()
    tail = for _ <- 1..(snake_len - 1), do: head_coords

    do_simulate_moves_long(moves, head_coords, tail, visited)
  end

  defp do_simulate_moves_long([{_, 0} | rest], head_coords, tail, visited) do
    do_simulate_moves_long(rest, head_coords, tail, visited)
  end

  defp do_simulate_moves_long([{dir, qty} | rest], head_coords, tail, visited) do
    new_head = move_head_by_dir(dir, head_coords)
    new_tail = move_tail(new_head, tail)

    do_simulate_moves_long(
      [{dir, qty - 1} | rest],
      new_head,
      new_tail,
      MapSet.put(visited, List.last(new_tail))
    )
  end

  defp do_simulate_moves_long([], _, _, visited), do: visited

  defp move_tail(cur, tail, acc \\ [])

  defp move_tail(cur, [next | rest], acc) do
    new_pos = calc_tail_coords(cur, next)

    move_tail(new_pos, rest, [new_pos | acc])
  end

  defp move_tail(_, [], acc), do: Enum.reverse(acc)

  defp move_head_by_dir(dir, {hx, hy}) do
    case dir do
      :right -> {hx + 1, hy}
      :left -> {hx - 1, hy}
      :up -> {hx, hy + 1}
      :down -> {hx, hy - 1}
    end
  end

  defp calc_tail_coords({hx, hy}, {tx, ty}) do
    case {abs(tx - hx), abs(ty - hy)} do
      {2, 2} -> {div(tx + hx, 2), div(ty + hy, 2)}
      {2, 0} -> {div(tx + hx, 2), ty}
      {2, 1} -> {div(tx + hx, 2), hy}
      {0, 2} -> {tx, div(ty + hy, 2)}
      {1, 2} -> {hx, div(ty + hy, 2)}
      _ -> {tx, ty}
    end
  end

  defp parse_input(input) do
    input
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [dir_str, qty_str] ->
      dir =
        case dir_str do
          "R" -> :right
          "L" -> :left
          "U" -> :up
          "D" -> :down
        end

      {dir, String.to_integer(qty_str)}
    end)
  end
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
