defmodule Monkey do
  defstruct [
    :id,
    :items,
    :operation,
    :test_by,
    :target_if_true,
    :target_if_false,
    inspected_qty: 0
  ]
end

defmodule Solution do
  def part1(input) do
    parse_monkeys(input)
    |> execute_rounds(20, &(div(&1, 3)))
    |> calc_monkey_business()
  end

  def part2(input) do
    monkeys_map = parse_monkeys(input)
    norm_factor = Map.values(monkeys_map) |> Enum.map(&(&1.test_by)) |> Enum.product()

    execute_rounds(monkeys_map, 10000, &(rem(&1, norm_factor)))
    |> calc_monkey_business()
  end

  defp execute_rounds(monkeys_state, 0, _div_fn), do: monkeys_state

  defp execute_rounds(monkeys_state, qty, div_fn) do
    monkey_ids = Map.keys(monkeys_state) |> Enum.sort()

    new_state =
      Enum.reduce(monkey_ids, monkeys_state, fn monkey_id, acc ->
        execute_turn(monkey_id, acc, div_fn)
      end)

    execute_rounds(new_state, qty - 1, div_fn)
  end

  defp execute_turn(monkey_id, monkeys_state, div_fn) do
    cur_monkey = monkeys_state[monkey_id]

    new_state =
      Enum.reduce(cur_monkey.items, monkeys_state, fn item, acc ->
        new_item =
          apply_operation(item, cur_monkey.operation)
          |> div_fn.()

        target_monkey_id =
          if rem(new_item, cur_monkey.test_by) == 0 do
            cur_monkey.target_if_true
          else
            cur_monkey.target_if_false
          end

        target_monkey = acc[target_monkey_id]

        %{acc | target_monkey_id => %{target_monkey | items: [new_item | target_monkey.items]}}
      end)

    updated_cur_monkey = %{
      cur_monkey
      | items: [],
        inspected_qty: cur_monkey.inspected_qty + length(cur_monkey.items)
    }

    %{new_state | monkey_id => updated_cur_monkey}
  end

  defp apply_operation(item, {el1, op, el2}) do
    case op do
      :+ -> apply_operation_val(item, el1) + apply_operation_val(item, el2)
      :* -> apply_operation_val(item, el1) * apply_operation_val(item, el2)
    end
  end

  defp apply_operation_val(item, :old), do: item
  defp apply_operation_val(_, el), do: el

  defp calc_monkey_business(monkeys_state) do
    Map.values(monkeys_state)
    |> Enum.map(& &1.inspected_qty)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end

  defp parse_monkeys(input, monkeys_map \\ Map.new())

  defp parse_monkeys(["Monkey " <> <<id_str::bytes-size(1)>> <> ":" | rest], monkeys_map) do
    id = String.to_integer(id_str)
    {monkey, rest_after} = parse_monkey(rest, %Monkey{id: id})
    parse_monkeys(rest_after, Map.put(monkeys_map, id, monkey))
  end

  defp parse_monkeys([], monkeys_map), do: monkeys_map

  defp parse_monkey(["  Starting items: " <> items_str | rest], monkey) do
    items =
      items_str
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.to_integer/1)

    parse_monkey(rest, %{monkey | items: items})
  end

  defp parse_monkey(["  Operation: new = " <> operation_str | rest], monkey) do
    operation =
      operation_str
      |> String.split(" ")
      |> Enum.map(fn term ->
        case term do
          "old" -> :old
          "+" -> :+
          "*" -> :*
          num -> String.to_integer(num)
        end
      end)
      |> List.to_tuple()

    parse_monkey(rest, %{monkey | operation: operation})
  end

  defp parse_monkey(["  Test: " <> test_str | rest], monkey) do
    "divisible by " <> divisible_factor_str = test_str
    divisible_factor = String.to_integer(divisible_factor_str)

    parse_monkey(rest, %{monkey | test_by: divisible_factor})
  end

  defp parse_monkey(["    If true: throw to monkey " <> monkey_id_str | rest], monkey) do
    parse_monkey(rest, %{monkey | target_if_true: String.to_integer(monkey_id_str)})
  end

  defp parse_monkey(["    If false: throw to monkey " <> monkey_id_str | rest], monkey) do
    parse_monkey(rest, %{monkey | target_if_false: String.to_integer(monkey_id_str)})
  end

  defp parse_monkey(["" | rest], monkey), do: {monkey, rest}

  defp parse_monkey(rest, monkey), do: {monkey, rest}
end

raw_input =
  IO.read(:stdio, :all)
  |> String.split("\n")

IO.inspect(Solution.part1(raw_input))
IO.inspect(Solution.part2(raw_input))
