defmodule Solution do
  @cube_sides_qty 6

  def part1(input) do
    parse_lava_coords(input)
    |> count_surface()
  end

  def part2(input) do
    all_voxels = parse_lava_coords(input)

    count_surface_convex_hull([{-1,-1,-1}], all_voxels, MapSet.new)
  end

  defp count_surface(voxels), do: do_count_surface(voxels, voxels)

  defp do_count_surface(rest_voxels, all_voxels, total \\ 0)

  defp do_count_surface([], _, total), do: total

  defp do_count_surface([voxel | voxels], all_voxels, total) do
    touched_by = get_neighbors(voxel) |> count_lava_neighbors(all_voxels)
    new_total = total + @cube_sides_qty - touched_by

    do_count_surface(voxels, all_voxels, new_total)
  end

  defp count_lava_neighbors(neighbors, all_voxels) do
    neighbors
    |> Enum.filter(fn near_voxel -> near_voxel in all_voxels end)
    |> Enum.count()
  end

  defp get_air_neighbors(neighbors, limits, all_voxels) do
    {limit_x, limit_y, limit_z} = limits

    neighbors
    |> Enum.filter(fn {x,y,z} -> x in limit_x and y in limit_y and z in limit_z end)
    |> Enum.filter(fn near_voxel -> near_voxel not in all_voxels end)
  end

  defp count_surface_convex_hull(air_to_visit, all_voxels, visited) do
    limits = get_min_max_limits(all_voxels)

    do_count_surface_convex_hull(air_to_visit, limits, all_voxels, visited, 0)
  end

  defp do_count_surface_convex_hull([], _, _, _, total), do: total

  defp do_count_surface_convex_hull([air_voxel | rest_to_visit], limits, all_voxels, visited, total) do
    if MapSet.member?(visited, air_voxel) do
      do_count_surface_convex_hull(rest_to_visit, limits, all_voxels, visited, total)
    else
      neighbors = get_neighbors(air_voxel)
      lava_neighbors_qty = count_lava_neighbors(neighbors, all_voxels)
      next_air_voxels = get_air_neighbors(neighbors, limits, all_voxels)
      new_visited = MapSet.put(visited, air_voxel)

      do_count_surface_convex_hull(rest_to_visit ++ next_air_voxels, limits, all_voxels, new_visited, total + lava_neighbors_qty)
    end
  end

  defp get_min_max_limits(all_voxels) do
    {min_x, max_x} = Enum.map(all_voxels, &elem(&1, 0)) |> Enum.min_max()
    {min_y, max_y} = Enum.map(all_voxels, &elem(&1, 1)) |> Enum.min_max()
    {min_z, max_z} = Enum.map(all_voxels, &elem(&1, 2)) |> Enum.min_max()

    {min(-1, min_x)..(max_x + 1), min(-1, min_y)..(max_y + 1), min(-1, min_z)..(max_z + 1)}
  end

  def get_neighbors({x, y, z}), do:
    [
      {x + 1, y, z},
      {x - 1, y, z},
      {x, y + 1, z},
      {x, y - 1, z},
      {x, y, z + 1},
      {x, y, z - 1},
    ]

  defp parse_lava_coords(input) do
    input
    |> Enum.map(fn line ->
      String.split(line, ",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
