defmodule AocDir do
  defstruct [:name, files: [], size: 0]
end

defmodule AocFile do
  defstruct [:name, :size]
end

defmodule Solution do
  @fs_delim "/"

  def part1(input) do
    parse_input(input)
    |> Map.values()
    |> Enum.map(&(&1.size))
    |> Enum.filter(fn size ->
      size <= 100000
    end)
    |> Enum.sum
  end

  def part2(input) do
    fs_map = parse_input(input)
    unused_space = 70_000_000 - fs_map[@fs_delim].size
    needed_space = 30_000_000 - unused_space

    fs_map
    |> Map.values()
    |> Enum.map(&(&1.size))
    |> Enum.sort()
    |> Enum.find(fn size ->
      size >= needed_space
    end)
  end

  defp parse_input(input), do: do_parse_input(@fs_delim, input, %{"/" => %AocDir{name: "/"}})

  defp do_parse_input(cur_dir, [line | rest], res) do
    case line do
      "$ cd /" ->
        do_parse_input(@fs_delim, rest, res)

      "$ cd .." ->
        do_parse_input(get_prev_dir(cur_dir), rest, res)

      "$ cd " <> dir_name ->
        do_parse_input(join_path(cur_dir, dir_name), rest, res)

      "$ ls" ->
        {new_rest, new_res} = list_dir(cur_dir, rest, res)
        do_parse_input(cur_dir, new_rest, new_res)
    end
  end

  defp do_parse_input(_, [], res), do: res

  defp join_path(cur_dir, dir), do: cur_dir <> dir <> @fs_delim

  defp get_prev_dir(cur_dir) do
    parts = String.split(cur_dir, @fs_delim)
    parts_len = length(parts)

    cond do
      parts_len > 1 -> List.delete_at(parts, parts_len - 2)
      true -> parts
    end
    |> Enum.join(@fs_delim)
  end

  defp list_dir(cur_dir, [line | rest], res) do
    case line do
      "$" <> _ ->
        {[line | rest], res}

      "dir " <> dir_name ->
        new_dir = %AocDir{name: join_path(cur_dir, dir_name)}

        if Map.has_key?(res, new_dir.name) do
          raise "Directory #{new_dir} already exists"
        end

        new_res = Map.put(res, new_dir.name, new_dir)

        list_dir(cur_dir, rest, new_res)

      _ ->
        [filesize, filename] = String.split(line, " ")
        new_file = %AocFile{name: filename, size: String.to_integer(filesize)}

        new_res =
          Map.get_and_update(res, cur_dir, fn dir ->
            {dir, Map.put(dir, :files, [new_file | dir.files])}
          end)
          |> elem(1)
          |> propagate_dir_size_increase(cur_dir, new_file.size)

        list_dir(cur_dir, rest, new_res)
    end
  end

  defp list_dir(_, [], res), do: {[], res}

  defp propagate_dir_size_increase(fs_map, "/", size) do
    Map.get_and_update(fs_map, "/", fn dir ->
      {dir, Map.put(dir, :size, dir.size + size)}
    end)
    |> elem(1)
  end

  defp propagate_dir_size_increase(fs_map, dir_path, size) do
    new_fs_map =
      Map.get_and_update(fs_map, dir_path, fn dir ->
        {dir, Map.put(dir, :size, dir.size + size)}
      end)
      |> elem(1)

    propagate_dir_size_increase(new_fs_map, get_prev_dir(dir_path), size)
  end
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
