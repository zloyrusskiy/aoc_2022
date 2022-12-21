defmodule Math do
  def get_manhattan_distance({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)
end

defmodule Sensor do
  defstruct [:x, :y, :beacon_x, :beacon_y, :power]
end

defmodule Solution do
  def part1(input) do
    sensors = parse_sensors(input)
    beacon_coords = sensors
    |> Enum.map(&{&1.beacon_x, &1.beacon_y})
    |> Enum.uniq()

    row = get_part1_row(sensors)

    find_coverage_for_row(sensors, row)
    |> remove_beacons(row, beacon_coords)
    |> collapse_ranges()
    |> count_in_ranges()
  end

  def part2(input) do
    sensors = parse_sensors(input)

    0..4_000_000
    |> Enum.find(fn row ->
      find_coverage_for_row(sensors, row)
      |> collapse_ranges()
      |> Enum.count
      |> Kernel.>(1)
    end)
    |> then(fn row ->
      ranges = find_coverage_for_row(sensors, row)
      |> collapse_ranges()

      x = hd(ranges).last + 1

      x * 4_000_000 + row
    end)
  end

  defp find_coverage_for_row(sensors, row) do
    sensors
    |> Enum.map(fn s ->
      y_diff = abs(s.y - row)
      x_diff = s.power - y_diff
      cond do
        x_diff < 0 -> :no_coverage
        true -> Range.new(s.x - x_diff, s.x + x_diff)
      end
    end)
    |> Enum.filter(&(&1 != :no_coverage))
  end

  defp remove_beacons(ranges, row, beacon_coords) do
    beacon_coords
    |> Enum.filter(fn {_,y} -> y == row end)
    |> Enum.map(fn {x, _} -> x end)
    |> Enum.reduce(ranges, fn x, ranges ->
      Enum.flat_map(ranges, fn range ->
        cond do
          x in range && Range.size(range) == 1 -> []
          x in range -> [Range.new(range.first, x - 1), Range.new(x + 1, range.last)]
          true -> [range]
        end
      end)
    end)
  end

  defp collapse_ranges(ranges) when is_list(ranges) do
    ranges
    |> Enum.sort_by(&(&1.first))
    |> Enum.reduce([], fn
      range, [] -> [range]

      range, [prev | rest ] ->
        cond do
          Range.disjoint?(range, prev) -> [range, prev | rest]
          true -> [Range.new(min(range.first, prev.first), max(range.last, prev.last)) | rest]
        end
    end)
    |> Enum.reverse()
  end

  defp count_in_ranges(ranges) when is_list(ranges) do
    ranges
    |> Enum.map(&Range.size/1)
    |> Enum.sum
  end

  defp get_part1_row(sensors) do
    cond do
      Enum.max_by(sensors, &(&1.y)).y < 100 -> 10
      true -> 2_000_000
    end
  end

  defp parse_sensors(input) do
    input
    |> Enum.map(fn line ->
      [x, y, b_x, b_y] = Regex.run(~r/Sensor at x=(\-?\d+), y=(\-?\d+): closest beacon is at x=(\-?\d+), y=(\-?\d+)/, line)
        |> tl
        |> Enum.map(&String.to_integer/1)

      power = Math.get_manhattan_distance({x,y}, {b_x, b_y})

      %Sensor{x: x, y: y, beacon_x: b_x, beacon_y: b_y, power: power}
    end)
  end
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
