defmodule Chamber do
  defstruct [:map, :row_top]
end

defmodule State do
  defstruct [:moves, :chamber]
end

defmodule Solution do
  @chamber_width 7
  @new_figure_col_start 2
  @new_figure_row_diff_start 3
  @rocks_limit_part1 2_022
  @rocks_limit_part2 1_000_000_000_000
  @shapes [
    # -
    [{0, 0}, {0, 1}, {0, 2}, {0, 3}],
    # +
    [{0, 1}, {1, 0}, {1, 1}, {1, 2}, {2, 1}],
    # ┘
    [{0, 0}, {0, 1}, {0, 2}, {1, 2}, {2, 2}],
    # |
    [{0, 0}, {1, 0}, {2, 0}, {3, 0}],
    # ▖
    [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  ]

  def part1(input) do
    moves = hd(input)
    chamber = %Chamber{map: Map.new(), row_top: 0}

    {_, last_state} =
      1..@rocks_limit_part1
      |> Enum.reduce(
        {@shapes, %State{moves: moves, chamber: chamber}},
        fn _, {[shape | shapes], state} ->
          figure = create_figure(shape, state.chamber)
          new_state = process_figure(figure, state)

          {shapes ++ [shape], new_state}
        end
      )

    last_state.chamber.row_top
  end

  def part2(input) do
    moves = hd(input)
    chamber = %Chamber{map: Map.new(), row_top: 0}

    {:ok, cur_index, cycle_start_index, history_map} = 1..@rocks_limit_part2
    |> Enum.reduce_while(
      {@shapes, %State{moves: moves, chamber: chamber}, Map.new(), Map.new()},
      fn index, {[shape | shapes], state, diffs_map, history_map} ->
        figure = create_figure(shape, state.chamber)
        new_state = process_figure(figure, state)
        chamber_map_diff = get_chambers_diff(state.chamber, new_state.chamber)
        diff_key = {state.moves, chamber_map_diff}

        if Map.has_key?(diffs_map, diff_key) do
          # got cycle length
          {:halt,
           {:ok, index, Map.get(diffs_map, diff_key), Map.put(history_map, index, new_state)}}
        else
          {:cont,
         {shapes ++ [shape], new_state, Map.put(diffs_map, diff_key, index),
          Map.put(history_map, index, new_state)}}
        end
      end
    )

    cycle_length = cur_index - cycle_start_index
    offset = cycle_start_index - 1
    cycle_elems_qty = div(@rocks_limit_part2 - offset, cycle_length)
    rest_elems_qty = rem(@rocks_limit_part2 - offset, cycle_length)
    before_cycle_height = Map.get(history_map, offset).chamber.row_top
    in_cycle_height = Map.get(history_map, cur_index - 1).chamber.row_top - before_cycle_height
    rest_height = Map.get(history_map, offset + rest_elems_qty).chamber.row_top - before_cycle_height

    before_cycle_height + in_cycle_height * cycle_elems_qty + rest_height
  end

  defp get_chambers_diff(prev, cur) do
    diff_coords = Map.keys(cur.map) -- Map.keys(prev.map)

    rmin =
      diff_coords
      |> Enum.map(&elem(&1, 0))
      |> Enum.min()

    diff_coords
    |> Enum.filter(fn {r, _} -> r >= rmin end)
    |> Enum.map(fn {r, c} -> {r - rmin + 1, c} end)
  end

  defp process_figure(figure, state) do
    <<move::bytes-size(1)>> <> rest_moves = state.moves
    new_moves = rest_moves <> move

    case try_move(move, figure, state.chamber) do
      {:ok, new_figure, new_chamber} ->
        process_figure(new_figure, %{state | moves: new_moves, chamber: new_chamber})

      {:stop, new_chamber} ->
        %{state | moves: new_moves, chamber: new_chamber}
    end
  end

  defp create_figure(shape, chamber) do
    nr = chamber.row_top + @new_figure_row_diff_start + 1
    nc = @new_figure_col_start + 1
    shape |> Enum.map(fn {sr, sc} -> {sr + nr, sc + nc} end)
  end

  defp try_move(move, figure, chamber) do
    case do_move(move, figure, chamber) do
      {:ok, figure_after_move} -> figure_after_move
      :blocked -> figure
    end
    |> do_fall(chamber)
  end

  defp do_move(move, figure, chamber) do
    figure_after_move =
      case move do
        "<" -> Enum.map(figure, fn {sr, sc} -> {sr, sc - 1} end)
        ">" -> Enum.map(figure, fn {sr, sc} -> {sr, sc + 1} end)
      end

    if have_collision?(figure_after_move, chamber) do
      :blocked
    else
      {:ok, figure_after_move}
    end
  end

  defp do_fall(figure, chamber) do
    figure_after_fall = Enum.map(figure, fn {sr, sc} -> {sr - 1, sc} end)

    if have_collision?(figure_after_fall, chamber) do
      new_chamber = add_figure_to_chamber(figure, chamber, ?#)
      figure_max_row = figure |> Enum.map(&elem(&1, 0)) |> Enum.max()
      new_row_top = max(chamber.row_top, figure_max_row)
      {:stop, %{new_chamber | row_top: new_row_top}}
    else
      {:ok, figure_after_fall, chamber}
    end
  end

  defp add_figure_to_chamber(figure, chamber, symb) do
    figure_map =
      figure
      |> Enum.map(&{&1, symb})
      |> Map.new()

    %{chamber | map: Map.merge(chamber.map, figure_map)}
  end

  defp have_collision?(figure, chamber) do
    Enum.any?(figure, fn {r, c} ->
      r < 1 or c < 1 or c > @chamber_width or Map.has_key?(chamber.map, {r, c})
    end)
  end

  defp draw_state(figure, chamber) do
    chamber_with_figure = add_figure_to_chamber(figure, chamber, ?@)

    (chamber.row_top + 6)..0
    |> Enum.each(fn row ->
      if row == 0 do
        IO.puts("+" <> String.duplicate("-", @chamber_width) <> "+")
      else
        line =
          1..@chamber_width
          |> Enum.map(fn col ->
            <<Map.get(chamber_with_figure.map, {row, col}, ?.)>>
          end)
          |> Enum.join()

        IO.puts("|" <> line <> "|")
      end
    end)
  end
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
